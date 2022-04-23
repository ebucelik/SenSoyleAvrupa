//
//  ProfileController.swift
//  SenSoyleAvrupa
//
//  Created by ilyas abiyev on 14.04.21.
//

import UIKit
import SideMenu
import Alamofire
import Combine
import ComposableArchitecture

import SwiftHelper

class ProfileController: UIViewController {

    // MARK: Properties
    private let store: Store<ProfileState, ProfileAction>
    private var viewStore: ViewStore<ProfileState, ProfileAction>
    private var cancellable: Set<AnyCancellable> = []
    private let email: String
    private let isOwnUserProfile: Bool
    private let collectionViewHeaderHeight: CGFloat = 200

    private var onDismiss: ((Bool) -> Void)?

    // MARK: Models
    private var userModel: UserModel? {
        didSet {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    private var videoDataModels = [VideoDataModel]() {
        didSet {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }

    // MARK: Views
    private let refreshControl = UIRefreshControl()
  
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .white
        return cv
    }()

    init(store: Store<ProfileState, ProfileAction>, userModel: UserModel? = nil, email: String, isOwnUserProfile: Bool = false) {
        self.store = store
        self.viewStore = ViewStore(store)
        self.email = email
        self.isOwnUserProfile = isOwnUserProfile

        super.init(nibName: nil, bundle: nil)

        self.onDismiss = { [self] modelDidChanged in
            if modelDidChanged {
                pullData()
            }
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.navigationBar.isHidden = false

        checkInternetConnection(completion: { self.pullData() })
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if isOwnUserProfile {
            navigationController?.navigationBar.prefersLargeTitles = true
            navigationController?.navigationItem.largeTitleDisplayMode = .always
            navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.customTintColor()]
        }

        setupStateChange()

        pullData()

        editLayout()
        
        editCollectionView()
    }

    func editLayout() {
        
        view.backgroundColor = .white

        view.addSubview(collectionView)

        collectionView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                              bottom: view.safeAreaLayoutGuide.bottomAnchor,
                              leading: view.leadingAnchor,
                              trailing: view.trailingAnchor,
                              padding: .init(top: 5, left: 20, bottom: 20, right: 20))

        if isOwnUserProfile {
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "line.horizontal.3"), style: .done, target: self, action: #selector(actionLeftMenu))
            navigationItem.leftBarButtonItem?.tintColor = .customTintColor()

            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "video.badge.plus"), style: .done, target: self, action: #selector(actionAddVideo))
            navigationItem.rightBarButtonItem?.tintColor = .customTintColor()
        }
    }

    func editCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(HeaderCollectionView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderCollectionView.identifer)
        collectionView.register(UINib(nibName: "ProfileVideoCell", bundle: nil), forCellWithReuseIdentifier: "ProfileVideoCell")

        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = CGSize(width: view.frame.width / 3.6, height: view.frame.width / 3.6)
            layout.minimumLineSpacing = 10
            layout.minimumInteritemSpacing = 10
        }
        
        refreshControl.addTarget(self, action: #selector(didPullToRefresh(_:)), for: .valueChanged)
        collectionView.alwaysBounceVertical = true
        collectionView.refreshControl = refreshControl
    }

    func setupStateChange() {
        viewStore.publisher.loadingUserModel
            .sink {
                self.loadingUserModelUpdated(state: $0)
            }
            .store(in: &cancellable)

        viewStore.publisher.userModel
            .sink { _ in
                self.userModelUpdated()
            }
            .store(in: &cancellable)

        viewStore.publisher.loadingVideoDataModel
            .sink {
                self.loadingVideoDataModelsUpdated(state: $0)
            }
            .store(in: &cancellable)

        viewStore.publisher.videoDataModels
            .sink { _ in
                self.videoDataModelsUpdated()
            }
            .store(in: &cancellable)
    }

    func loadingUserModelUpdated(state: UserModelLoadingState) {
        switch state {
        case .none, .loaded, .error:
            view.hideLoading()

        case .loading, .refreshing:
            view.showLoading()
        }
    }

    func userModelUpdated() {
        guard let userModel = viewStore.userModel else { return }

        self.userModel = userModel
    }

    func loadingVideoDataModelsUpdated(state: VideoDataModelLoadingState) {
        switch state {
        case .none, .loaded, .error:
            view.hideLoading()

        case .loading, .refreshing:
            view.showLoading()
        }
    }

    func videoDataModelsUpdated() {
        guard let videoDataModels = viewStore.videoDataModels else { return }

        self.videoDataModels = videoDataModels
    }

    @objc private func didPullToRefresh(_ sender: Any) {
        pullData()
        refreshControl.endRefreshing()
    }
    
    @objc func actionLeftMenu() {
        print("left menu")
        var menu: SideMenuNavigationController?
        menu = SideMenuNavigationController(rootViewController: LeftMenuController(onDismiss: onDismiss))
        menu?.leftSide = true
        menu?.statusBarEndAlpha = 0
        menu?.navigationController?.navigationBar.isHidden = true
        menu?.presentationStyle = .viewSlideOutMenuPartialIn
        SideMenuManager.default.leftMenuNavigationController = menu
        SideMenuManager.default.addPanGestureToPresent(toView: self.view)

        guard let menu = menu else {
            return
        }

        present(menu, animated: true)
    }

    @objc func actionAddVideo() {
        let vc = ShareVideoController(store: .init(initialState: ShareVideoState(),
                                                   reducer: shareVideoReducer,
                                                   environment: ShareVideoEnvironment(service: Services.shareVideoService,
                                                                                      mainQueue: .main)))
        vc.onDismiss = onDismiss

        let navigationVC = UINavigationController(rootViewController: vc)
        navigationVC.modalPresentationStyle = .fullScreen
        present(navigationVC, animated: true)
    }

    func pullData() {
        viewStore.send(.loadUser(email: email))
    }
}

extension ProfileController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videoDataModels.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileVideoCell", for: indexPath) as! ProfileVideoCell
        let model = videoDataModels[indexPath.row]
        cell.configureVideo(model: model)
        return cell
    }
}

extension ProfileController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model = videoDataModels[indexPath.row]

        if model.email == nil {
            model.email = email
        }

        let videoController = ProfileVideoController(model: model, service: Services.sharedService)
        videoController.onDismiss = onDismiss

        present(videoController, animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderCollectionView.identifer, for: indexPath) as! HeaderCollectionView

        header.buttonEditProfile.isHidden = !isOwnUserProfile

        if isOwnUserProfile {
            header.buttonEditProfile.addTarget(self, action: #selector(actionEditProfile), for: .touchUpInside)
        }

        header.labelEmail.text = email
        header.labelVideoCount.text = "\(videoDataModels.count)"

        guard let userModel = userModel else { return header }
        header.userModel = userModel

        return header
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.size.width, height: collectionViewHeaderHeight)
    }

    @objc func actionEditProfile() {
        let vc = EditProfileController(service: Services.sharedService)
        vc.onDismiss = onDismiss

        navigationController?.navigationBar.tintColor = .customLabelColor()
        navigationController?.pushViewController(vc, animated: true)
    }
}
