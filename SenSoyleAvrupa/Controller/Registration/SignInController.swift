//
//  SignInController.swift
//  SenSoyleAvrupa
//
//  Created by ilyas abiyev on 13.04.21.
//

import UIKit
import Alamofire
import Combine
import ComposableArchitecture

class SignInController: UITableViewController {

    // MARK: Properties
    var store: Store<LoginState, LoginAction>
    var viewStore: ViewStore<LoginState, LoginAction>
    var cancellables: Set<AnyCancellable> = []

    // MARK: Views
    let allView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    lazy var buttonDismiss: UIButton = {
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
        lbl.text = "Merhaba!\nGiriş yap"
        lbl.textColor = .customLabelColor()
        lbl.textAlignment = .left
        lbl.font = .systemFont(ofSize: 30, weight: .heavy)
        lbl.numberOfLines = 0
        return lbl
    }()

    let labelEmail: UILabel = {
        let lbl = UILabel()
        lbl.text = "E-Postanız"
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
        textField.textColor = .black
        textField.text = ""
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
        textField.textColor = .black
        textField.text = ""
        return textField
    }()
    
    lazy var buttonForgotPassword: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Parolanızı mı unuttunuz?", for: .normal)
        btn.contentHorizontalAlignment = .right
        btn.setTitleColor(.black, for: .normal)
        btn.addTarget(self, action: #selector(actionForgotPassword), for: .touchUpInside)
        return btn
    }()
    
    lazy var buttonSignIn: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Giriş Yap", for: .normal)
        btn.backgroundColor = .customTintColor()
        btn.titleLabel?.tintColor = .white
        btn.titleLabel?.font = .systemFont(ofSize: 17, weight: .heavy)
        btn.layer.cornerRadius = 15
        btn.heightAnchor.constraint(equalToConstant: 50).isActive = true
        btn.addTarget(self, action: #selector(actionSignIn), for: .touchUpInside)
        return btn
    }()

    init(store: Store<LoginState, LoginAction>) {
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
                                                       labelPassword,
                                                       textFieldPassword,
                                                       buttonForgotPassword,
                                                       buttonSignIn])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.setCustomSpacing(20, after: buttonForgotPassword)

        allView.addSubview(buttonDismiss)
        allView.addSubview(stackView)

        buttonDismiss.anchor(top: allView.safeAreaLayoutGuide.topAnchor, leading: allView.leadingAnchor, padding: .init(top: 20, left: 20, bottom: 0, right: 0))
        
        stackView.anchor(top: buttonDismiss.bottomAnchor, leading: allView.leadingAnchor, trailing: allView.trailingAnchor, padding: .init(top: 20, left: 20, bottom: 0, right: 20))
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
            .store(in: &cancellables)

        viewStore.publisher.signUpModel
            .sink { [self] _ in
                signUpModelUpdated()
            }
            .store(in: &cancellables)
    }

    func loadingSignUpModelUpdated(state: SignUpModelLoadingState) {
        switch state {
        case .none, .loaded, .error:
            allView.hideLoading()

        case .loading, .refreshing:
            allView.showLoading()
        }
    }

    func signUpModelUpdated() {
        guard let signUpModel = viewStore.signUpModel else { return }

        if signUpModel.status == true {
            UserDefaults.standard.set(viewStore.email, forKey: SplashViewController.userDefaultsEmailKey)
            CacheUser.email = viewStore.email

            let vc = SplashViewController(service: Services.sharedService)
            let navigationVC = UINavigationController(rootViewController: vc)
            navigationVC.modalPresentationStyle = .fullScreen
            present(navigationVC, animated: true, completion: nil)
        } else {
            makeAlert(title: "Hata", message: "Profil Oluşturarken bir hata oluştu: \(signUpModel.message ?? "")")
        }
    }

    @objc func actionSignIn() {
        print("sign in")
        let email = textFieldEmail.text?.trim().lowercased() ?? ""
        let password = textFieldPassword.text?.trim() ?? ""
        
        if email.isEmpty || password.isEmpty {
            showSnackBar(message: "Lütfen tüm alanları giriniz")
            return
        }

        viewStore.send(.login(email: email, password: password))
    }

    @objc func actionForgotPassword() {
        guard let url = URL(string: "https://sensoyleavrupa.com/login/yeni-sifre.php") else { return }
        let webViewController = WebViewController(url: url)
        present(webViewController, animated: true, completion: nil)

        //navigationController?.pushViewController(ForgotPasswordController(), animated: true)
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
