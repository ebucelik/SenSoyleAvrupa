//
//  ChooseProfileImageController.swift
//  SenSoyleAvrupa
//
//  Created by ilyas abiyev on 14.04.21.
//

import UIKit
import Alamofire
import TTGSnackbar
import CoreData

class ChooseProfileImageController: UIViewController {
    
    let context = appDelegate.persistentContainer.viewContext
    
    var userArray = [UserData]()
    
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
        lbl.text = "Choose your\nProfile picture"
        lbl.textColor = .customLabelColor()
        lbl.textAlignment = .left
        lbl.font = .systemFont(ofSize: 30, weight: .heavy)
        lbl.numberOfLines = 0
        return lbl
    }()
    
    let centerView : UIView = {
       let view = UIView()
        view.heightAnchor.constraint(equalToConstant: 180).isActive = true
        view.widthAnchor.constraint(equalToConstant: 180).isActive = true
        view.layer.cornerRadius = 90
        view.backgroundColor = UIColor.white
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.5
        view.layer.shadowOffset = CGSize.zero
        view.layer.shadowRadius = 5
        return view
    }()
    
    var bigCircle: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.widthAnchor.constraint(equalToConstant: 180).isActive = true
        view.heightAnchor.constraint(equalToConstant: 180).isActive = true
        return view
    }()
    
    var littleCircle: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.widthAnchor.constraint(equalToConstant: 60).isActive = true
        view.heightAnchor.constraint(equalToConstant: 60).isActive = true
        view.backgroundColor = .white
        return view
    }()
    
    let profilImage : UIImageView = {
        let img = UIImageView(image: UIImage(named: "emojiman"))
        img.backgroundColor = .white
        img.layer.borderWidth = 10
        img.layer.borderColor = UIColor.customTintColor().cgColor
        img.widthAnchor.constraint(equalToConstant: 180).isActive = true
        img.heightAnchor.constraint(equalToConstant: 180).isActive = true
        img.layer.cornerRadius = 90
        img.clipsToBounds = true
        img.layer.masksToBounds = true
        img.translatesAutoresizingMaskIntoConstraints = false
        img.contentMode = .scaleAspectFit
        return img
    }()
    
    let editImage : UIImageView = {
        let img = UIImageView(image: UIImage(systemName: "plus.circle"))
        img.widthAnchor.constraint(equalToConstant: 60).isActive = true
        img.heightAnchor.constraint(equalToConstant: 60).isActive = true
        img.layer.cornerRadius = 30
        img.clipsToBounds = true
        img.layer.masksToBounds = true
        img.translatesAutoresizingMaskIntoConstraints = false
        img.contentMode = .scaleAspectFill
        img.tintColor = .customLabelColor()
        return img
    }()
    
    let btnNext : UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Next", for: .normal)
        btn.backgroundColor = .lightGray
        btn.alpha = 0.5
        btn.titleLabel?.tintColor = .darkGray
        btn.isUserInteractionEnabled = false
        btn.titleLabel?.font = .systemFont(ofSize: 17, weight: .heavy)
        btn.layer.cornerRadius = 15
        btn.heightAnchor.constraint(equalToConstant: 50).isActive = true
        btn.addTarget(self, action: #selector(actionNext), for: .touchUpInside)
        return btn
    }()
    
    let loadingView = LoadingView()
    
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
    }
 
    func editLayout() {
        view.backgroundColor = .white
        
        view.addSubview(btnLeft)
        
        view.addSubview(lblTop)
        
        view.addSubview(bigCircle)
        
        bigCircle.addSubview(profilImage)
        
        bigCircle.addSubview(littleCircle)
        
        littleCircle.addSubview(editImage)
        
        view.addSubview(btnNext)
        
        view.addSubview(loadingView)
        
        
        btnLeft.anchor(top: view.safeAreaLayoutGuide.topAnchor, bottom: nil, leading: view.leadingAnchor, trailing: nil,padding: .init(top: 20, left: 20, bottom: 0, right: 0))
        
        lblTop.anchor(top: btnLeft.bottomAnchor, bottom: nil, leading: view.leadingAnchor, trailing: nil,padding: .init(top: 20, left: 20, bottom: 0, right: 0))
        
        profilImage.doldurSuperView()
        
        editImage.anchor(top: littleCircle.topAnchor, bottom: littleCircle.bottomAnchor, leading: littleCircle.leadingAnchor, trailing: littleCircle.trailingAnchor)
        
        bigCircle.merkezKonumlamdirmaSuperView()
        
        btnNext.anchor(top: nil, bottom: view.safeAreaLayoutGuide.bottomAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor,padding: .init(top: 0, left: 20, bottom: 20, right: 20))
        
        
        loadingView.doldurSuperView()
        
        loadingView.isHidden = true
        
        
        let gestureEdit = UITapGestureRecognizer(target: self, action: #selector(actionEdit))
        littleCircle.addGestureRecognizer(gestureEdit)
        
        let (hMult, vMult) = computeMultipliers(angle: 45)
        
        NSLayoutConstraint(item: littleCircle, attribute: .centerX, relatedBy: .equal, toItem: bigCircle, attribute: .trailing, multiplier: hMult, constant: 0).isActive = true
        NSLayoutConstraint(item: littleCircle, attribute: .centerY, relatedBy: .equal, toItem: bigCircle, attribute: .bottom, multiplier: vMult, constant: 0).isActive = true
    }
    
    
    
    @objc func actionLeft() {
        let alert = UIAlertController(title: "Çıkış Yap", message: "Çıkıs yapmak istediğinizden eminmisiniz?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Evet", style: .default, handler: { [self] (_) in
            do{
                userArray = try context.fetch(UserData.fetchRequest())
                
            }catch{
                print("Error Pull Data")
            }
            
            CacheUser.email = ""
           
          
            let user = userArray[0]

            context.delete(user)

            appDelegate.saveContext()
            
            let vc = SplashViewController()
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "İptal et", style: .cancel))
        present(alert, animated: true, completion: nil)
       
    }
    
    @objc func actionEdit() {
        let imgPickerController = UIImagePickerController()
        imgPickerController.delegate = self
        present(imgPickerController, animated: true, completion: nil)
    }
    
    @objc func actionNext() {
        
        
        if profilImage.image == UIImage(named: "emojiman") {
            let snackBar = TTGSnackbar(message: "Lütfen profil fotoğrafı ekleyin", duration: .middle)
            snackBar.show()
            return
        }
       
        
        loadingView.isHidden = false
        
        let parameters = ["email" : CacheUser.email
        ]
        
        AF.upload(multipartFormData: { multipartFormData in
            
            for (key, value) in parameters {
                multipartFormData.append(value.data(using: .utf8)!, withName: key)
            }
            
            if let jpegData = self.profilImage.image!.jpegData(compressionQuality: 1.0) {
                multipartFormData.append(jpegData, withName: "file", fileName: "file", mimeType: ".png")
            }
        }, to: "\(NetworkManager.url)/api/upload-pp")
        .response { response in
            print(response)
            if response.response?.statusCode == 200 {
                print("OK. Done")
                let vc = SplashViewController()
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true, completion: nil)
                
            }
        }
        
        
    }
    
   
    
    func computeMultipliers(angle: CGFloat) -> (CGFloat, CGFloat) {
        let radians = angle * .pi / 180
        
        let h = (1.0 + cos(radians)) / 2
        let v = (1.0 - sin(radians)) / 2
        
        return (h, v)
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        bigCircle.layer.cornerRadius = 0.5 * bigCircle.frame.height
        
        littleCircle.layoutIfNeeded()
        littleCircle.layer.cornerRadius = 0.5 * littleCircle.frame.height
        
    }
    
    

}


extension ChooseProfileImageController : UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let imgSecilen = info[.originalImage] as? UIImage
        self.profilImage.image = imgSecilen?.withRenderingMode(.alwaysOriginal)
        editImage.image = UIImage(systemName: "checkmark.circle")
        btnNext.backgroundColor = .customTintColor()
        btnNext.titleLabel?.tintColor = .white
        btnNext.alpha = 1
        btnNext.isUserInteractionEnabled = true
        profilImage.layer.masksToBounds = true
        profilImage.contentMode = .scaleAspectFill
        dismiss(animated: true, completion: nil)
    }
}
