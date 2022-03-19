//
//  WelcomeChooseController.swift
//  SenSoyleAvrupa
//
//  Created by ilyas abiyev on 13.04.21.
//

import UIKit

class WelcomeChooseController: UIViewController {

    // MARK: Views
    lazy var imageViewLogo: UIImageView = {
        let img = UIImageView(image: #imageLiteral(resourceName: "Character1Color1"))
        img.widthAnchor.constraint(equalToConstant: view.frame.width / 2).isActive = true
        img.heightAnchor.constraint(equalToConstant: view.frame.width / 2).isActive = true
        img.clipsToBounds = false
        return img
    }()
    
    let labelTitle: UILabel = {
        let lbl = UILabel()
        lbl.text = "Sen Söyle Avrupa"
        lbl.textColor = .customLabelColor()
        lbl.textAlignment = .center
        lbl.font = .boldSystemFont(ofSize: 23)
        return lbl
    }()
    
    let labelDescription: UILabel = {
        let lbl = UILabel()
        lbl.text = "Lorem Ipsum is simply dummy text of the printing and typesetting industry."
        lbl.textColor = .gray
        lbl.textAlignment = .center
        lbl.font = .systemFont(ofSize: 15)
        lbl.numberOfLines = 0
        return lbl
    }()
    
    let buttonSignUp: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Kayıt Ol", for: .normal)
        btn.backgroundColor = .customTintColor()
        btn.titleLabel?.tintColor = .white
        btn.titleLabel?.font = .systemFont(ofSize: 17, weight: .heavy)
        btn.layer.cornerRadius = 15
        btn.heightAnchor.constraint(equalToConstant: 50).isActive = true
        btn.addTarget(self, action: #selector(actionSignUp), for: .touchUpInside)
        return btn
    }()
    
    let buttonSignIn: UIButton = {
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
    }
    
    func editLayout() {
        view.backgroundColor = .white
        
        let stackView = UIStackView(arrangedSubviews: [labelTitle, labelDescription])
        stackView.axis = .vertical
        stackView.spacing = 15
        
        let buttonStackView = UIStackView(arrangedSubviews: [buttonSignUp, buttonSignIn])
        buttonStackView.axis = .horizontal
        buttonStackView.spacing = 15
        buttonStackView.distribution = .fillEqually
        
        view.addSubview(imageViewLogo)
        view.addSubview(stackView)
        view.addSubview(buttonStackView)
        
        imageViewLogo.centerViewAtSuperView()
        
        stackView.anchor(top: imageViewLogo.bottomAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor, padding: .init(top: 20, left: 30, bottom: 0, right: 30))
        
        buttonStackView.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor, padding: .init(top: 0, left: 20, bottom: 20, right: 20))
    }
    
    @objc func actionSignUp() {
        navigationController?.pushViewController(SignUpController(
            store: .init(initialState: RegistrationState(),
                         reducer: registrationReducer,
                         environment: RegistrationEnvironment(service: Services.registrationService,
                                                              mainQueue: .main))), animated: true)
    }

    @objc func actionSignIn() {
        navigationController?.pushViewController(SignInController(
            store: .init(initialState: LoginState(),
                         reducer: loginReducer,
                         environment: LoginEnvironment(service: Services.loginService,
                                                       mainQueue: .main))), animated: true)
    }
}
