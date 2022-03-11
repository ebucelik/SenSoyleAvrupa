//
//  SignUpController.swift
//  SenSoyleAvrupa
//
//  Created by ilyas abiyev on 13.04.21.
//

import UIKit
import AIFlatSwitch
import TTGSnackbar
import Alamofire
import CoreData

//let parameters : Parameters = ["username" : nickname,"email":email,"password":password]
//
//AF.request("https://cknuls.gq/api/register",method: .post,parameters: parameters).responseJSON { response in
//
//    if let data = response.data {
//        do {
//            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] {
//                print("Json succes : \(json)")
//            }
//        }catch{
//            print("Json error : \(error.localizedDescription)")
//        }
//    }
//
//}


class SignUpController: UITableViewController {
    
    let context = appDelegate.persistentContainer.viewContext
    
    let allView : UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    let loadingView = LoadingView()
    
    
    let btnLeft : UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        btn.tintColor = .customTintColor()
        btn.heightAnchor.constraint(equalToConstant: 36).isActive = true
        btn.widthAnchor.constraint(equalToConstant: 36).isActive = true
        btn.addTarget(self, action: #selector(actionLeft), for: .touchUpInside)
        btn.layer.cornerRadius = 18
        btn.backgroundColor = .customBackgroundColor()
        return btn
    }()
    
    let lblTop : UILabel = {
        let lbl = UILabel()
        lbl.text = "Hesap\noluştur"
        lbl.textColor = .customLabelColor()
        lbl.textAlignment = .left
        lbl.font = .systemFont(ofSize: 30, weight: .heavy)
        lbl.numberOfLines = 0
        return lbl
    }()
    
    let imgProfile : UIImageView = {
        let img = UIImageView(image: UIImage(named: ""))
        img.heightAnchor.constraint(equalToConstant: 50).isActive = true
        img.widthAnchor.constraint(equalToConstant: 50).isActive = true
        img.layer.cornerRadius = 5
        img.clipsToBounds = true
        img.backgroundColor = .customTintColor()
        return img
    }()
    
    
    let lblYourMail : UILabel = {
        let lbl = UILabel()
        lbl.text = "Mail adresiniz"
        lbl.textColor = .black
        lbl.font = .boldSystemFont(ofSize: 15)
        return lbl
    }()
    
    let txtMail : UITextField = {
        let textField = CustomTextField()
        //textField.backgroundColor = .init(white: 0.92, alpha: 1)
        textField.backgroundColor = .customBackgroundColor()
        textField.placeholder = ""
        textField.layer.cornerRadius = 5
        textField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        textField.text = ""
        textField.textColor = .black
        return textField
    }()
    
    let lblNickName : UILabel = {
        let lbl = UILabel()
        lbl.text = "Kullanıcı adınız"
        lbl.textColor = .black
        lbl.font = .boldSystemFont(ofSize: 15)
        return lbl
    }()
    
    let txtNickName : UITextField = {
        let textField = CustomTextField()
        //textField.backgroundColor = .init(white: 0.92, alpha: 1)
        textField.backgroundColor = .customBackgroundColor()
        textField.placeholder = ""
        textField.layer.cornerRadius = 5
        textField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        textField.text = ""
        textField.textColor = .black
        return textField
    }()
    
    let lblPassword : UILabel = {
        let lbl = UILabel()
        lbl.text = "Parolanız"
        lbl.textColor = .black
        lbl.font = .boldSystemFont(ofSize: 15)
        return lbl
    }()
    
    let txtPassword : UITextField = {
        let textField = CustomTextField()
        //textField.backgroundColor = .init(white: 0.92, alpha: 1)
        textField.backgroundColor = .customBackgroundColor()
        textField.placeholder = ""
        textField.layer.cornerRadius = 5
        textField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        textField.isSecureTextEntry = true
        textField.text = ""
        textField.textColor = .black
        return textField
    }()
    
    lazy var privacyPolciySwitchView : UIView = {
        let view = UIView()
        view.heightAnchor.constraint(equalToConstant: 30).isActive = true
        return view
    }()
    
    let lblPrivacyPolicy : UILabel = {
        let lbl = UILabel()
        let attributed = NSMutableAttributedString(string: " Gizlilik Politikası ve Hizmet Şartları", attributes: [.font : UIFont.systemFont(ofSize: 12,weight: .heavy),.foregroundColor : UIColor.black])
        attributed.append(NSAttributedString(string: "'nı okudum ve kabul ediyorum.", attributes: [.font : UIFont.systemFont(ofSize: 12),.foregroundColor : UIColor.black]))
        lbl.attributedText = attributed
        lbl.numberOfLines = 0
        lbl.isUserInteractionEnabled = true
        lbl.textAlignment = .center
        return lbl
    }()
    
    var flatSwitch : AIFlatSwitch = {
        let view = AIFlatSwitch()
        view.heightAnchor.constraint(equalToConstant: 26).isActive = true
        view.widthAnchor.constraint(equalToConstant: 26).isActive = true
        view.isUserInteractionEnabled = true
        view.isSelected = false
        view.strokeColor = UIColor.customLabelColor()
        view.trailStrokeColor = UIColor.customLabelColor()
        return view
    }()
    
    let btnSignUp : UIButton = {
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
    
    let btnSignIn : UIButton = {
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
        
        if CheckInternet.Connection() {
            
        }else{
            let vc = NoInternetController()
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        editLayout()
        
        editTableView()
    }
    
    func editLayout() {
        tableView.backgroundColor = .white
        
        let stackView = UIStackView(arrangedSubviews: [lblYourMail,txtMail,lblNickName,txtNickName,lblPassword,txtPassword,privacyPolciySwitchView])
        stackView.axis = .vertical
        stackView.spacing = 10
        
        let stackViewBtn = UIStackView(arrangedSubviews: [btnSignUp,btnSignIn])
        stackViewBtn.axis = .vertical
        stackViewBtn.spacing = 10
        
        allView.addSubview(btnLeft)
        
        allView.addSubview(lblTop)
        
        allView.addSubview(stackView)
        
        allView.addSubview(stackViewBtn)
        
        allView.addSubview(loadingView)
        
        btnLeft.anchor(top: allView.safeAreaLayoutGuide.topAnchor, bottom: nil, leading: allView.leadingAnchor, trailing: nil,padding: .init(top: 20, left: 20, bottom: 0, right: 0))
        
        lblTop.anchor(top: btnLeft.bottomAnchor, bottom: nil, leading: allView.leadingAnchor, trailing: nil,padding: .init(top: 20, left: 20, bottom: 0, right: 0))
        
        stackView.anchor(top: lblTop.bottomAnchor, bottom: nil, leading: allView.leadingAnchor, trailing: allView.trailingAnchor,padding: .init(top: 20, left: 20, bottom: 0, right: 20))
        
        stackViewBtn.anchor(top: stackView.bottomAnchor, bottom: nil, leading: allView.leadingAnchor, trailing: allView.trailingAnchor,padding: .init(top: 30, left: 20, bottom: 0, right: 20))
        
        
        //Switch View
        privacyPolciySwitchView.addSubview(flatSwitch)
        
        privacyPolciySwitchView.addSubview(lblPrivacyPolicy)
        

        flatSwitch.anchor(top: nil, bottom: nil, leading: privacyPolciySwitchView.leadingAnchor ,trailing: nil,padding: .init(top: 0, left: 5, bottom: 0, right: 5))
        flatSwitch.centerYAtSuperView()
        
        
        lblPrivacyPolicy.anchor(top: nil, bottom: nil, leading: flatSwitch.trailingAnchor, trailing: privacyPolciySwitchView.trailingAnchor,padding: .init(top: 0, left: 0, bottom: 0, right: 5))
        
        lblPrivacyPolicy.centerYAtSuperView()
        
        loadingView.addToSuperViewAnchors()
        
        let gestureSwitch = UITapGestureRecognizer(target: self, action: #selector(actionPrivacyPolicy))
        lblPrivacyPolicy.addGestureRecognizer(gestureSwitch)
        
        loadingView.isHidden = true
        
    }
    
    func editTableView() {
        tableView.tableFooterView = UIView()
        tableView.keyboardDismissMode = .interactive
        tableView.allowsMultipleSelection = false
    }

    @objc func actionLeft() {
        print("left")
        navigationController?.popViewController(animated: true)
    }
    
    @objc func actionPrivacyPolicy() {
        print("privacy polciy")
        navigationController?.pushViewController(PrivacyPolicyTermsofService(), animated: true)
    }
    
    @objc func actionCreateAccount() {
        print("create account")
        
        let email = txtMail.text ?? ""
        let username = txtNickName.text ?? ""
        let password = txtPassword.text ?? ""

        if email == "" || username == "" || password == "" {
            let snackBar = TTGSnackbar(message: "Lütfen tüm alanları giriniz", duration: .middle)
            snackBar.show()
            return
        }

        if flatSwitch.isSelected == false {
            let snackBar = TTGSnackbar(message: "Lütfen Gizlilik kuralları ve Kullanıcı sözleşmesini okuyun ve kabul edin", duration: .middle)
            snackBar.show()
            return
        }

        loadingView.isHidden = false

        let parameters : Parameters = ["username": username, "email": email, "password": password]
        
        AF.request("\(NetworkManager.url)/api/register", method: .post, parameters: parameters).responseString { [self] response in
            print(response)
            if let data = response.data {
                do {
                    let answer = try JSONDecoder().decode(SignUpModel.self, from: data)

                    if let status = answer.status, status {
                        let user = UserData(context: context)
                        user.email = email
                        appDelegate.saveContext()

                        let vc = SplashViewController()
                        let navigationVC = UINavigationController(rootViewController: vc)
                        navigationVC.modalPresentationStyle = .fullScreen
                        present(navigationVC, animated: true, completion: nil)
                    } else {
                        loadingView.isHidden = true
                        self.makeAlert(title: "Hata", message: "Profil Oluşturarken bir hata oluştu: \(answer.message ?? "")")
                    }
                    
                }catch{
                    loadingView.isHidden = true
                    makeAlert(title: "Error Localized Description", message: "\(error.localizedDescription)")
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

