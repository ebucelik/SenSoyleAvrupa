//
//  SignInController.swift
//  SenSoyleAvrupa
//
//  Created by ilyas abiyev on 13.04.21.
//

import UIKit
import TTGSnackbar
import Alamofire

class SignInController: UITableViewController {

    let context = appDelegate.persistentContainer.viewContext
    
    let allView : UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    let loadingView = LoadingView()
    
    let snackBar = TTGSnackbar(message: "Message", duration: .middle)
    
    let btnLeft : UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        btn.tintColor = .customTintColor()
        btn.heightAnchor.constraint(equalToConstant: 36).isActive = true
        btn.widthAnchor.constraint(equalToConstant: 36).isActive = true
        btn.addTarget(self, action: #selector(actionLeft), for: .touchUpInside)
        btn.layer.cornerRadius = 18
        btn.backgroundColor = .customBackgorundButton()
        return btn
    }()
    
    let lblTop : UILabel = {
        let lbl = UILabel()
        lbl.text = "Merhaba!\nGiriş yap"
        lbl.textColor = .customLabelColor()
        lbl.textAlignment = .left
        lbl.font = .systemFont(ofSize: 30, weight: .heavy)
        lbl.numberOfLines = 0
        return lbl
    }()
    
    
    let lblYourMail : UILabel = {
        let lbl = UILabel()
        lbl.text = "E-Postanız"
        lbl.textColor = .black
        lbl.font = .boldSystemFont(ofSize: 15)
        return lbl
    }()
    
    let txtMail : UITextField = {
       let textField = CustomTextField()
        //textField.backgroundColor = .init(white: 0.92, alpha: 1)
        textField.backgroundColor = .customBackgorundButton()
        textField.placeholder = ""
        textField.layer.cornerRadius = 5
        textField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        textField.textColor = .black
        textField.text = ""
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
        textField.backgroundColor = .customBackgorundButton()
        textField.placeholder = ""
        textField.layer.cornerRadius = 5
        textField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        textField.isSecureTextEntry = true
        textField.textColor = .black
        textField.text = ""
        return textField
    }()
    
    let btnForgotPassword : UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Parolanızı mı unuttunuz?", for: .normal)
        btn.contentHorizontalAlignment = .right
        btn.setTitleColor(.black, for: .normal)
        btn.addTarget(self, action: #selector(actionForgotPassword), for: .touchUpInside)
        return btn
    }()
    
    let btnSingIn : UIButton = {
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
        
        let stackView = UIStackView(arrangedSubviews: [lblYourMail,txtMail,lblPassword,txtPassword,btnForgotPassword])
        stackView.axis = .vertical
        stackView.spacing = 10
        
        let stackViewBtn = UIStackView(arrangedSubviews: [btnSingIn])
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
        
        stackViewBtn.anchor(top: stackView.bottomAnchor, bottom: nil, leading: allView.leadingAnchor, trailing: allView.trailingAnchor,padding: .init(top: 20, left: 20, bottom: 0, right: 20))
        
        
        
        loadingView.doldurSuperView()
        
      
        
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
    
    @objc func actionSignIn() {
        print("sign in")
        let email = txtMail.text?.trim().lowercased() ?? ""
        let password = txtPassword.text?.trim() ?? ""
        
        if email == "" || password == "" {
            let snackBar = TTGSnackbar(message: "Lütfen tüm alanları giriniz", duration: .middle)
            snackBar.show()
            return
        }
        
        loadingView.isHidden = false
        
        let parameters : Parameters = ["email":email,"password":password]
     
        AF.request("\(NetworkManager.url)/api/login",method: .get,parameters: parameters).responseJSON { [self] response in
            
            print("response: \(response)")
            
            if let data = response.data {
                do {
                    let answer = try JSONDecoder().decode(SignUp.self, from: data)
                    
                    if answer.status == true {
                        let user = UserData(context: context)
                        user.email = email
                        print("Save Core Data Email \(email)")
                        appDelegate.saveContext()
                      
                        let vc = SplashViewController()
                        let navigationVC = UINavigationController(rootViewController: vc)
                        navigationVC.modalPresentationStyle = .fullScreen
                        present(navigationVC, animated: true, completion: nil)
                    }else{
                        loadingView.isHidden = true
                        self.makeAlert(tittle: "Hata", message: "Profil Oluşturarken bir hata oluştu: \(answer.message ?? "")")
                    }
                }catch{
                    loadingView.isHidden = true
                    makeAlert(tittle: "Error Localized Description", message: "\(error.localizedDescription)")
                }
            }
            
        }
        
    }
    
    @objc func actionForgotPassword() {
        print("action forgot password")
        navigationController?.pushViewController(ForgotPasswordController(), animated: true)
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
