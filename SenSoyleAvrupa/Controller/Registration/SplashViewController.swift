//
//  SplashViewController.swift
//  SenSoyleAvrupa
//
//  Created by ilyas abiyev on 13.04.21.
//

import UIKit
import Alamofire

class SplashViewController: UIViewController {

    // MARK: Properties
    private let service: SharedServiceProtocol
    static let userDefaultsEmailKey = "userEmail"

    // MARK: Views
    lazy var imageViewLogo: UIImageView = {
        let img = UIImageView(image: UIImage(named: "Character1Color1"))
        img.widthAnchor.constraint(equalToConstant: view.frame.width / 1.5).isActive = true
        img.heightAnchor.constraint(equalToConstant: view.frame.width / 1.5).isActive = true
        img.clipsToBounds = false
        return img
    }()

    init(service: SharedServiceProtocol) {
        self.service = service

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = true
        
        checkInternetConnection(completion: { [self] in
            editLayout()
            pullData()
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        editLayout()
        
        pullData()
    }
    
    func editLayout() {
        view.backgroundColor = .white
        
        view.addSubview(imageViewLogo)
        
        imageViewLogo.centerViewAtSuperView()
    }

    func pullData() {
        if let userDefaultsEmail = UserDefaults.standard.string(forKey: SplashViewController.userDefaultsEmailKey) {
            CacheUser.email = userDefaultsEmail

            service.pullUserData(email: CacheUser.email) { [self] in
                if $0.pp == "\(NetworkManager.url)/pp" {
                    perform(#selector(actionChooseProfileImage))
                } else {
                    perform(#selector(actionTabBar), with: nil, afterDelay: 1)
                }
            }
        } else if CacheUser.email.isEmpty {
            perform(#selector(actionWelcomePage), with: nil, afterDelay: 3)
        } else {
            perform(#selector(actionWelcomePage), with: nil, afterDelay: 3)
        }
    }

    @objc func actionTabBar() {
        let vc = CustomTabbar()
        let navigationVC = UINavigationController(rootViewController: vc)
        navigationVC.modalPresentationStyle = .fullScreen
        present(navigationVC, animated: true)
    }

    @objc func actionWelcomePage() {
        let vc = WelcomeChooseController()
        let navigationVC = UINavigationController(rootViewController: vc)
        navigationVC.modalPresentationStyle = .fullScreen
        present(navigationVC, animated: true)
    }

    @objc func actionChooseProfileImage() {
        let vc = ChooseProfileImageController(
            store: .init(initialState: ChooseProfileImageState(),
                         reducer: chooseProfileImageReducer,
                         environment: ChooseProfileImageEnvironment(service: Services.chooseProfileImageService, mainQueue: .main)))
        let navigationVC = UINavigationController(rootViewController: vc)
        navigationVC.modalPresentationStyle = .fullScreen
        present(navigationVC, animated: true)
    }
}
