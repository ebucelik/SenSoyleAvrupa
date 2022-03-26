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

class ProfileController: UIViewController {

    // MARK: Properties
    private let store: Store<ProfileState, ProfileAction>
    private var viewStore: ViewStore<ProfileState, ProfileAction>
    private var cancellable: Set<AnyCancellable> = []
    private let email: String
    private let isOwnUserProfile: Bool
    private let collectionViewHeaderHeight: CGFloat = 200

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
    private let loadingView = LoadingView()
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

        setupStateChange()

        pullData()

        editLayout()
        
        editCollectionView()
    }

    func editLayout() {
        
        view.backgroundColor = .white

        view.addSubview(collectionView)
        view.addSubview(loadingView)

        collectionView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                              bottom: view.safeAreaLayoutGuide.bottomAnchor,
                              leading: view.leadingAnchor,
                              trailing: view.trailingAnchor,
                              padding: .init(top: 5, left: 20, bottom: 0, right: 20))

        loadingView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                           bottom: view.safeAreaLayoutGuide.bottomAnchor,
                           leading: view.leadingAnchor,
                           trailing: view.trailingAnchor,
                           padding: .init(top: collectionViewHeaderHeight))

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
            loadingView.isHidden = true

        case .loading, .refreshing:
            loadingView.isHidden = false
        }
    }

    func userModelUpdated() {
        guard let userModel = viewStore.userModel else { return }

        self.userModel = userModel
    }

    func loadingVideoDataModelsUpdated(state: VideoDataModelLoadingState) {
        switch state {
        case .none, .loaded, .error:
            loadingView.isHidden = true

        case .loading, .refreshing:
            loadingView.isHidden = false
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
        var menu : SideMenuNavigationController?
        menu = SideMenuNavigationController(rootViewController: LeftMenuController())
        menu?.leftSide = true
        menu?.statusBarEndAlpha = 0
        menu?.navigationController?.navigationBar.isHidden = true
        menu?.presentationStyle = .viewSlideOutMenuPartialIn
        SideMenuManager.default.leftMenuNavigationController = menu
        SideMenuManager.default.addPanGestureToPresent(toView: self.view)
        present(menu!, animated: true)
    }

    @objc func actionAddVideo() {
        let vc = ShareVideoController(store: .init(initialState: ShareVideoState(),
                                                   reducer: shareVideoReducer,
                                                   environment: ShareVideoEnvironment(service: Services.shareVideoService,
                                                                                      mainQueue: .main)))
        vc.onDismiss = { [self] modelDidChanged in
            if modelDidChanged {
                pullData()
            }
        }

        let navigationVC = UINavigationController(rootViewController: vc)
        navigationVC.modalPresentationStyle = .fullScreen
        present(navigationVC, animated: true)
    }

    func pullData() {
        if let userModel = userModel {
            viewStore.send(.loadVideos(email: email, userId: userModel.id ?? 0))
        } else {
            viewStore.send(.loadUser(email: email))
        }
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

        let videoController = VideoController(model: model, service: Services.sharedService)
        videoController.onDismiss = { modelDidChanged in
            if modelDidChanged {
                self.pullData()
            }
        }

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
        vc.onDismiss = { [self] modelDidChanged in
            if modelDidChanged {
                viewStore.send(.loadUser(email: email))
            }
        }

        navigationController?.pushViewController(vc, animated: true)
    }
}
