//
//  NoInternetController.swift
//  WebiView
//
//  Created by ilyas abiyev on 07.04.21.
//

import UIKit

class NoInternetController: UIViewController {
    
    lazy var imgEmoji : UIImageView = {
        let img = UIImageView(image: #imageLiteral(resourceName: "Character1Color1"))
        img.widthAnchor.constraint(equalToConstant: view.frame.width / 2).isActive = true
        img.heightAnchor.constraint(equalToConstant: view.frame.width / 2).isActive = true
        img.clipsToBounds = false
        return img
    }()
    
    let lblOops : UILabel = {
       let lbl = UILabel()
        lbl.text = "Oops!"
        lbl.textColor = .customTintColor()
        //lbl.textColor = #colorLiteral(red: 0.4912128448, green: 0.3343035579, blue: 1, alpha: 1)
        lbl.textAlignment = .center
        lbl.font = .systemFont(ofSize: 23, weight: .heavy)
        return lbl
    }()
    
    let lblNoInternet : UILabel = {
        let lbl = UILabel()
        lbl.text = "İnternet bağlantısı yok\nLütfen internet bağlantınızı kontrol edin"
        lbl.textColor = .black
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        return lbl
    }()
    
    let btnTryAgain : UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Tekrar deneyin", for: .normal)
        btn.titleLabel?.font = .boldSystemFont(ofSize: 17)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .customTintColor()
        btn.heightAnchor.constraint(equalToConstant: 50).isActive = true
        btn.widthAnchor.constraint(equalToConstant: 180).isActive = true
        btn.layer.cornerRadius = 25
        btn.addTarget(self, action: #selector(actionTryAgain), for: .touchUpInside)
        return btn
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        
        if CheckInternet.Connection() {
            dismiss(animated: true, completion: nil)
        }else {
          
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        editLayout()
    }
    
    func editLayout() {
        let stactView = UIStackView(arrangedSubviews: [lblOops,lblNoInternet])
        stactView.axis = .vertical
        stactView.spacing = 20
        
        view.backgroundColor = .white
        
        view.addSubview(imgEmoji)
        
        view.addSubview(stactView)
        
        view.addSubview(btnTryAgain)

        imgEmoji.merkezKonumlamdirmaSuperView()

        stactView.anchor(top: imgEmoji.bottomAnchor, bottom: nil, leading: view.leadingAnchor, trailing: view.trailingAnchor,padding: .init(top: 20, left: 30, bottom: 0, right: 30))
        
        btnTryAgain.anchor(top: nil, bottom: view.safeAreaLayoutGuide.bottomAnchor, leading: nil, trailing: nil,padding: .init(top: 20, left: 85, bottom: 30, right: 85))
        btnTryAgain.merkezXSuperView()
    }
    

    @objc func actionTryAgain() {
        print("tryagain")
        if CheckInternet.Connection() {
            dismiss(animated: true, completion: nil)
        }else {
          
        }
    }

}
