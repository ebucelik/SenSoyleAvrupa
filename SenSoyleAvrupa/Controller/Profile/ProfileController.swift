//
//  ProfileController.swift
//  SenSoyleAvrupa
//
//  Created by ilyas abiyev on 14.04.21.
//

import UIKit
import SideMenu
import Alamofire

class ProfileController: UIViewController {

    private struct State {
        var oldUserModel: UserModel?
        var oldVideoDataModels: [VideoDataModel]
    }

    // MARK: Variables
    private let email: String
    private let isOwnUserProfile: Bool
    private var state: State
    private let service: ViewControllerServiceProtocol

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
  
    let collectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .white
        return cv
    }()

    init(userModel: UserModel? = nil, email: String, service: ViewControllerService, isOwnUserProfile: Bool = false) {
        self.userModel = userModel
        self.email = email
        self.service = service
        self.isOwnUserProfile = isOwnUserProfile
        self.state = State(oldUserModel: userModel, oldVideoDataModels: videoDataModels)

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.navigationBar.isHidden = false

        checkInternetConnection()

        didPullToRefresh(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        pullData()

        editLayout()
        
        editCollectionView()
    }

    func editLayout() {
        
        view.backgroundColor = .white
        
        view.addSubview(collectionView)
        
        collectionView.anchor(top: view.safeAreaLayoutGuide.topAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor,padding: .init(top: 5, left: 0, bottom: 0, right: 0))

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
            layout.itemSize = CGSize(width: view.frame.width / 3.2, height: view.frame.width / 3.2)
            layout.minimumLineSpacing = 6
            layout.minimumInteritemSpacing = 5
            layout.sectionInset = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        }
        
        refreshControl.addTarget(self, action: #selector(didPullToRefresh(_:)), for: .valueChanged)
        collectionView.alwaysBounceVertical = true
        collectionView.refreshControl = refreshControl
    }
    
    @objc private func didPullToRefresh(_ sender: Any) {
        pullData()
        refreshControl.endRefreshing()
    }
    
    
    @objc func actionLeftMenu() {
        print("left menu")
        var menu : SideMenuNavigationController?
        menu = SideMenuNavigationController(rootViewController:LeftMenuController())
        menu?.leftSide = true
        menu?.statusBarEndAlpha = 0
        menu?.navigationController?.navigationBar.isHidden = true
        menu?.presentationStyle = .viewSlideOutMenuPartialIn
        SideMenuManager.default.leftMenuNavigationController = menu
        SideMenuManager.default.addPanGestureToPresent(toView: self.view)
        present(menu!, animated: true, completion: nil)
    }

    @objc func actionAddVideo() {
        let vc = ShareVideoController()
        let navigationVC = UINavigationController(rootViewController: vc)
        navigationVC.modalPresentationStyle = .fullScreen
        present(navigationVC, animated: true, completion: nil)
    }

    func pullData() {
        service.pullUserData(email: email) { [self] userModel in
            if state.oldUserModel != userModel {
                state.oldUserModel = userModel
                self.userModel = userModel
            }

            service.pullProfileData(email: email, userId: userModel.id ?? 0) { videoDataModels in
                if state.oldVideoDataModels != videoDataModels {
                    state.oldVideoDataModels = videoDataModels
                    self.videoDataModels = videoDataModels
                }
            }
        }
    }
}

extension ProfileController : UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videoDataModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileVideoCell", for: indexPath) as! ProfileVideoCell
        let model = videoDataModels[indexPath.row]
        cell.configureVideo(model: model)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model = videoDataModels[indexPath.row]

        if model.email == nil {
            model.email = email
        }

        let videoController = VideoController(model: model, service: ViewControllerService())
        videoController.onDismiss = { modelDidChanged in
            if modelDidChanged {
                self.pullData()
            }
        }

        present(videoController, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderCollectionView.identifer, for: indexPath) as! HeaderCollectionView
        header.btnEditProfile.addTarget(self, action: #selector(actionEditProfile), for: .touchUpInside)
        header.lblMail.text = email
        header.lblVideoCount.text = "\(videoDataModels.count)"

        guard let userModel = userModel else { return header }

        if let pp = userModel.pp, pp != "\(NetworkManager.url)/public/pp" {
            header.imgProfile.sd_setImage(with: URL(string: pp), completed: nil)
        }

        header.lblCoinCount.text = "\(userModel.coin ?? 0)"
        header.lblPuahCount.text = "\(userModel.points ?? 0)"
        header.lblName.text = userModel.username

        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.size.width, height: 200)
    }
    
    @objc func actionEditProfile() {
        let vc = EditProfileController(service: ViewControllerService())
        navigationController?.pushViewController(vc, animated: true)
    }
}
