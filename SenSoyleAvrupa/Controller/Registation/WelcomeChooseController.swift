//
//  WelcomeChooseController.swift
//  SenSoyleAvrupa
//
//  Created by ilyas abiyev on 13.04.21.
//

import UIKit

class WelcomeChooseController: UIViewController {
    
    lazy var imgLogo : UIImageView = {
        let img = UIImageView(image: #imageLiteral(resourceName: "Character1Color1"))
        img.widthAnchor.constraint(equalToConstant: view.frame.width / 2).isActive = true
        img.heightAnchor.constraint(equalToConstant: view.frame.width / 2).isActive = true
        img.clipsToBounds = false
        return img
    }()
    
    let lblTitle : UILabel = {
        let lbl = UILabel()
        lbl.text = "Sen Söyle Avrupa"
        lbl.textColor = .customLabelColor()
        lbl.textAlignment = .center
        lbl.font = .boldSystemFont(ofSize: 23)
        return lbl
    }()
    
    let lblDescription : UILabel = {
        let lbl = UILabel()
        lbl.text = "Lorem Ipsum is simply dummy text of the printing and typesetting industry."
        lbl.textColor = .gray
        lbl.textAlignment = .center
        lbl.font = .systemFont(ofSize: 15)
        lbl.numberOfLines = 0
        return lbl
    }()
    
    let btnSignUp : UIButton = {
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
        
        editLayot()
    }
    
    
    func editLayot() {
        view.backgroundColor = .white
        
        let stackView = UIStackView(arrangedSubviews: [lblTitle,lblDescription])
        stackView.axis = .vertical
        stackView.spacing = 15
        
        let btnStackView = UIStackView(arrangedSubviews: [btnSignUp,btnSignIn])
        btnStackView.axis = .horizontal
        btnStackView.spacing = 15
        btnStackView.distribution = .fillEqually
        
        view.addSubview(imgLogo)
        
        view.addSubview(stackView)
        
        view.addSubview(btnStackView)
        
        imgLogo.merkezKonumlamdirmaSuperView()
        
        stackView.anchor(top: imgLogo.bottomAnchor, bottom: nil, leading: view.leadingAnchor, trailing: view.trailingAnchor,padding: .init(top: 20, left: 30, bottom: 0, right: 30))
        
        btnStackView.anchor(top: nil, bottom: view.safeAreaLayoutGuide.bottomAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor,padding: .init(top: 0, left: 20, bottom: 20, right: 20))
    }
    
    @objc func actionSignUp() {
        navigationController?.pushViewController(SignUpController(), animated: true)
    }
    
    @objc func actionSignIn() {
        navigationController?.pushViewController(SignInController(), animated: true)
    }
    
}
