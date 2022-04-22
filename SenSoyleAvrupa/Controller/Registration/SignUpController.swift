//
//  SignUpController.swift
//  SenSoyleAvrupa
//
//  Created by ilyas abiyev on 13.04.21.
//

import UIKit
import AIFlatSwitch
import Alamofire
import Combine
import ComposableArchitecture

import SwiftHelper

class SignUpController: UITableViewController {

    // MARK: Properties
    var store: Store<RegistrationState, RegistrationAction>
    var viewStore: ViewStore<RegistrationState, RegistrationAction>
    var cancellable: Set<AnyCancellable> = []

    // MARK: Views
    let allView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    let loadingView = LoadingView()

    let buttonDismiss: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        btn.tintColor = .customTintColor()
        btn.heightAnchor.constraint(equalToConstant: 36).isActive = true
        btn.widthAnchor.constraint(equalToConstant: 36).isActive = true
        btn.addTarget(self, action: #selector(dismissViewController), for: .touchUpInside)
        btn.layer.cornerRadius = 18
        btn.backgroundColor = .customBackgroundColor()
        return btn
    }()
    
    let labelTitle: UILabel = {
        let lbl = UILabel()
        lbl.text = "Hesap\noluştur"
        lbl.textColor = .customLabelColor()
        lbl.textAlignment = .left
        lbl.font = .systemFont(ofSize: 30, weight: .heavy)
        lbl.numberOfLines = 0
        return lbl
    }()
    
    let imageViewProfileImage: UIImageView = {
        let img = UIImageView(image: UIImage(named: ""))
        img.heightAnchor.constraint(equalToConstant: 50).isActive = true
        img.widthAnchor.constraint(equalToConstant: 50).isActive = true
        img.layer.cornerRadius = 5
        img.clipsToBounds = true
        img.backgroundColor = .customTintColor()
        return img
    }()
    
    let labelEmail: UILabel = {
        let lbl = UILabel()
        lbl.text = "Mail adresiniz"
        lbl.textColor = .black
        lbl.font = .boldSystemFont(ofSize: 15)
        return lbl
    }()
    
    let textFieldEmail: UITextField = {
        let textField = CustomTextField()
        textField.backgroundColor = .customBackgroundColor()
        textField.placeholder = ""
        textField.layer.cornerRadius = 5
        textField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        textField.text = ""
        textField.textColor = .black
        return textField
    }()
    
    let labelUsername: UILabel = {
        let lbl = UILabel()
        lbl.text = "Kullanıcı adınız"
        lbl.textColor = .black
        lbl.font = .boldSystemFont(ofSize: 15)
        return lbl
    }()
    
    let textFieldUsername: UITextField = {
        let textField = CustomTextField()
        textField.backgroundColor = .customBackgroundColor()
        textField.placeholder = ""
        textField.layer.cornerRadius = 5
        textField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        textField.text = ""
        textField.textColor = .black
        return textField
    }()
    
    let labelPassword: UILabel = {
        let lbl = UILabel()
        lbl.text = "Parolanız"
        lbl.textColor = .black
        lbl.font = .boldSystemFont(ofSize: 15)
        return lbl
    }()
    
    let textFieldPassword: UITextField = {
        let textField = CustomTextField()
        textField.backgroundColor = .customBackgroundColor()
        textField.placeholder = ""
        textField.layer.cornerRadius = 5
        textField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        textField.isSecureTextEntry = true
        textField.text = ""
        textField.textColor = .black
        return textField
    }()
    
    lazy var viewPrivacyPolicy: UIView = {
        let view = UIView()
        view.heightAnchor.constraint(equalToConstant: 30).isActive = true
        return view
    }()
    
    let labelPrivacyPolicy: UILabel = {
        let lbl = UILabel()
        let attributed = NSMutableAttributedString(string: " Gizlilik Politikası ve Hizmet Şartları",
                                                   attributes: [.font: UIFont.systemFont(ofSize: 12,weight: .heavy),
                                                                .foregroundColor: UIColor.black])
        attributed.append(NSAttributedString(string: "'nı okudum ve kabul ediyorum.",
                                             attributes: [.font: UIFont.systemFont(ofSize: 12),
                                                          .foregroundColor: UIColor.black]))
        lbl.attributedText = attributed
        lbl.numberOfLines = 0
        lbl.isUserInteractionEnabled = true
        lbl.textAlignment = .center
        return lbl
    }()
    
    var flatSwitch: AIFlatSwitch = {
        let view = AIFlatSwitch()
        view.heightAnchor.constraint(equalToConstant: 26).isActive = true
        view.widthAnchor.constraint(equalToConstant: 26).isActive = true
        view.isUserInteractionEnabled = true
        view.isSelected = false
        view.strokeColor = UIColor.customLabelColor()
        view.trailStrokeColor = UIColor.customLabelColor()
        return view
    }()
    
    let btnSignUp: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Hesap oluştur", for: .normal)
        btn.backgroundColor = .customTintColor()
        btn.titleLabel?.tintColor = .white
        btn.titleLabel?.font = .systemFont(ofSize: 17, weight: .heavy)
        btn.layer.cornerRadius = 15
        btn.heightAnchor.constraint(equalToConstant: 50).isActive = true
        btn.addTarget(self, action: #selector(actionCreateAccount), for: .touchUpInside)
        return btn
    }()
    
    let btnSignIn: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Giriş Yap", for: .normal)
        btn.backgroundColor = .white
        btn.titleLabel?.tintColor = .customTintColor()
        btn.titleLabel?.font = .systemFont(ofSize: 17, weight: .heavy)
        btn.layer.cornerRadius = 15
        btn.layer.borderWidth = 2
        btn.layer.borderColor = UIColor.customTintColor().cgColor
        btn.heightAnchor.constraint(equalToConstant: 50).isActive = true
        btn.addTarget(self, action: #selector(actionSignIn), for: .touchUpInside)
        return btn
    }()

    init(store: Store<RegistrationState, RegistrationAction>) {
        self.store = store
        self.viewStore = ViewStore(store)

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        
        checkInternetConnection(completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        editLayout()
        
        editTableView()

        setupStateObservers()
    }

    func editLayout() {
        tableView.backgroundColor = .white
        
        let stackView = UIStackView(arrangedSubviews: [labelTitle,
                                                       labelEmail,
                                                       textFieldEmail,
                                                       labelUsername,
                                                       textFieldUsername,
                                                       labelPassword,
                                                       textFieldPassword,
                                                       viewPrivacyPolicy,
                                                       btnSignUp,
                                                       btnSignIn])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.setCustomSpacing(40, after: viewPrivacyPolicy)
        
        allView.addSubview(buttonDismiss)
        allView.addSubview(stackView)
        allView.addSubview(loadingView)
        
        buttonDismiss.anchor(top: allView.safeAreaLayoutGuide.topAnchor, leading: allView.leadingAnchor, padding: .init(top: 20, left: 20, bottom: 0, right: 0))
        
        stackView.anchor(top: buttonDismiss.bottomAnchor, leading: allView.leadingAnchor, trailing: allView.trailingAnchor, padding: .init(top: 20, left: 20, bottom: 0, right: 20))

        //Switch View
        viewPrivacyPolicy.addSubview(flatSwitch)
        viewPrivacyPolicy.addSubview(labelPrivacyPolicy)

        flatSwitch.anchor(leading: viewPrivacyPolicy.leadingAnchor, padding: .init(horizontal: 5))
        flatSwitch.centerYAtSuperView()

        labelPrivacyPolicy.anchor(leading: flatSwitch.trailingAnchor, trailing: viewPrivacyPolicy.trailingAnchor, padding: .init(right: 5))
        labelPrivacyPolicy.centerYAtSuperView()

        loadingView.addToSuperViewAnchors()

        let gestureSwitch = UITapGestureRecognizer(target: self, action: #selector(actionPrivacyPolicy))
        labelPrivacyPolicy.addGestureRecognizer(gestureSwitch)

        loadingView.isHidden = true
    }
    
    func editTableView() {
        tableView.tableFooterView = UIView()
        tableView.keyboardDismissMode = .interactive
        tableView.allowsMultipleSelection = false
    }

    func setupStateObservers() {
        viewStore.publisher.loadingSignUpModel
            .sink { [self] in
                loadingSignUpModelUpdated(state: $0)
            }
            .store(in: &cancellable)

        viewStore.publisher.signUpModel
            .sink { [self] _ in
                signUpModelUpdated()
            }
            .store(in: &cancellable)
    }

    func loadingSignUpModelUpdated(state: SignUpModelLoadingState) {
        switch state {
        case .none, .loaded, .error:
            loadingView.isHidden = true

        case .loading, .refreshing:
            loadingView.isHidden = false
        }
    }

    func signUpModelUpdated() {
        guard let signUpModel = viewStore.signUpModel else { return }

        if let status = signUpModel.status, status {
            UserDefaults.standard.set(viewStore.email, forKey: SplashViewController.userDefaultsEmailKey)
            CacheUser.email = viewStore.email

            let vc = SplashViewController(service: Services.sharedService)
            let navigationVC = UINavigationController(rootViewController: vc)
            navigationVC.modalPresentationStyle = .fullScreen
            present(navigationVC, animated: true)
        } else {
            makeAlert(title: "Hata", message: "Profil Oluşturarken bir hata oluştu: \(signUpModel.message ?? "")")
        }
    }

    @objc func actionPrivacyPolicy() {
        print("privacy polciy")
        navigationController?.pushViewController(PrivacyPolicyTermsofService(), animated: true)
    }
    
    @objc func actionCreateAccount() {
        print("create account")
        
        let email = textFieldEmail.text ?? ""
        let username = textFieldUsername.text ?? ""
        let password = textFieldPassword.text ?? ""

        if email.isEmpty || username.isEmpty || password.isEmpty {
            showSnackBar(message: "Lütfen tüm alanları giriniz")
            return
        }

        if email.checkEmailValidation() {
            showSnackBar(message: "E-Mail'iniz hatali. Lütfen dogru E-Mail kullanin.")
            return
        }

        if username.count < 6 {
            showSnackBar(message: "Kullanıcı adınız minimum 6 karakter'li olmali.")
            return
        }

        if password.count < 8 {
            showSnackBar(message: "Parolanız minimum 6 karakter'li olmali.")
            return
        }

        if !flatSwitch.isSelected {
            showSnackBar(message: "Lütfen Gizlilik kuralları ve Kullanıcı sözleşmesini okuyun ve kabul edin")
            return
        }

        viewStore.send(.register(username: username, email: email, password: password))
    }
    
    @objc func actionSignIn() {
        print("go to sign in")
        navigationController?.pushViewController(SignInController(
            store: .init(initialState: LoginState(),
                         reducer: loginReducer,
                         environment: LoginEnvironment(service: Services.loginService,
                                                       mainQueue: .main))),
                                                 animated: true)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return allView
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return view.frame.size.height
    }
}
