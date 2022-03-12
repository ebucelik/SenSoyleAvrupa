//
//  SignUpController.swift
//  SenSoyleAvrupa
//
//  Created by ilyas abiyev on 13.04.21.
//

import UIKit
import AIFlatSwitch
import Alamofire

class SignUpController: UITableViewController {
    
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
    
    let labelEmailTitle: UILabel = {
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
    
    let textFieldPassword : UITextField = {
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        
        checkInternetConnection(completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        editLayout()
        
        editTableView()
    }
    
    func editLayout() {
        tableView.backgroundColor = .white
        
        let stackView = UIStackView(arrangedSubviews: [labelEmailTitle,textFieldEmail,labelUsername,textFieldUsername,labelPassword,textFieldPassword,viewPrivacyPolicy])
        stackView.axis = .vertical
        stackView.spacing = 10
        
        let stackViewBtn = UIStackView(arrangedSubviews: [btnSignUp,btnSignIn])
        stackViewBtn.axis = .vertical
        stackViewBtn.spacing = 10
        
        allView.addSubview(buttonDismiss)
        allView.addSubview(labelTitle)
        allView.addSubview(stackView)
        allView.addSubview(stackViewBtn)
        allView.addSubview(loadingView)
        
        buttonDismiss.anchor(top: allView.safeAreaLayoutGuide.topAnchor, leading: allView.leadingAnchor, padding: .init(top: 20, left: 20, bottom: 0, right: 0))
        
        labelTitle.anchor(top: buttonDismiss.bottomAnchor, leading: allView.leadingAnchor, padding: .init(top: 20, left: 20, bottom: 0, right: 0))
        
        stackView.anchor(top: labelTitle.bottomAnchor, leading: allView.leadingAnchor, trailing: allView.trailingAnchor,padding: .init(top: 20, left: 20, bottom: 0, right: 20))
        
        stackViewBtn.anchor(top: stackView.bottomAnchor, leading: allView.leadingAnchor, trailing: allView.trailingAnchor,padding: .init(top: 30, left: 20, bottom: 0, right: 20))

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

        loadingView.isHidden = false

        let parameters: Parameters = ["username": username, "email": email, "password": password]

        NetworkManager.call(endpoint: "/api/register", method: .post, parameters: parameters) { [self] (result: Result<SignUpModel, Error>) in
            switch result {
            case let .failure(error):
                print("Network request error: \(error)")

                loadingView.isHidden = true
                makeAlert(title: "Error Localized Description", message: "\(error.localizedDescription)")
            case let .success(signUpModel):
                if let status = signUpModel.status, status {
                    UserDefaults.standard.set(email, forKey: SplashViewController.userDefaultsEmailKey)
                    CacheUser.email = email

                    let vc = SplashViewController(service: ViewControllerService())
                    let navigationVC = UINavigationController(rootViewController: vc)
                    navigationVC.modalPresentationStyle = .fullScreen
                    present(navigationVC, animated: true, completion: nil)
                } else {
                    loadingView.isHidden = true
                    makeAlert(title: "Hata", message: "Profil Oluşturarken bir hata oluştu: \(signUpModel.message ?? "")")
                }
            }
        }
    }
    
    @objc func actionSignIn() {
        print("go to sign in")
        navigationController?.pushViewController(SignInController(), animated: true)
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
