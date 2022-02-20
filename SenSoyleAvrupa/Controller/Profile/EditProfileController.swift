//
//  EditProfileController.swift
//  SenSoyleAvrupa
//
//  Created by ilyas abiyev on 17.04.21.
//

import UIKit
import Alamofire

class EditProfileController: UIViewController {
    
    
    
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
        img.contentMode = .scaleAspectFill
        return img
    }()
    
    let editImage : UIImageView = {
        let img = UIImageView(image: UIImage(systemName: "pencil.circle"))
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
        btn.setTitle("Güncelle", for: .normal)
        btn.backgroundColor = .customTintColor()
        btn.titleLabel?.tintColor = .white
        btn.titleLabel?.font = .systemFont(ofSize: 17, weight: .heavy)
        btn.layer.cornerRadius = 15
        btn.heightAnchor.constraint(equalToConstant: 50).isActive = true
        btn.addTarget(self, action: #selector(actionNext), for: .touchUpInside)
        return btn
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
        textField.backgroundColor = .customBackgorundButton()
        textField.layer.cornerRadius = 5
        textField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        textField.textColor = .black
        return textField
    }()
    
    let loadingView = LoadingView()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        pullData()  
        
        navigationController?.navigationBar.isHidden = false
        
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
        title = "Profili Düzenle"
        
        view.backgroundColor = .white
        
        let stackView = UIStackView(arrangedSubviews: [lblNickName,txtNickName,btnNext])
        stackView.axis = .vertical
        stackView.spacing = 10
        
        view.addSubview(bigCircle)
        
        bigCircle.addSubview(profilImage)
        
        bigCircle.addSubview(littleCircle)
        
        littleCircle.addSubview(editImage)
        
        view.addSubview(stackView)
        
        view.addSubview(loadingView)
        
        
        bigCircle.anchor(top: view.safeAreaLayoutGuide.topAnchor, bottom: nil, leading: nil, trailing: nil,padding: .init(top: 20, left: 0, bottom: 0, right: 0))
        bigCircle.centerXAtSuperView()
        
        profilImage.addToSuperViewAnchors()
        
        editImage.anchor(top: littleCircle.topAnchor, bottom: littleCircle.bottomAnchor, leading: littleCircle.leadingAnchor, trailing: littleCircle.trailingAnchor)
        
        stackView.anchor(top: profilImage.bottomAnchor, bottom: nil, leading: view.leadingAnchor, trailing: view.trailingAnchor,padding: .init(top: 10, left: 20, bottom: 0, right: 20))
        
        loadingView.addToSuperViewAnchors()
        
        loadingView.isHidden = true
        
        let gestureEdit = UITapGestureRecognizer(target: self, action: #selector(actionEdit))
        littleCircle.addGestureRecognizer(gestureEdit)
        
        let (hMult, vMult) = computeMultipliers(angle: 45)
        
        NSLayoutConstraint(item: littleCircle, attribute: .centerX, relatedBy: .equal, toItem: bigCircle, attribute: .trailing, multiplier: hMult, constant: 0).isActive = true
        NSLayoutConstraint(item: littleCircle, attribute: .centerY, relatedBy: .equal, toItem: bigCircle, attribute: .bottom, multiplier: vMult, constant: 0).isActive = true
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
    
    @objc func actionEdit() {
        let imgPickerController = UIImagePickerController()
        imgPickerController.delegate = self
        present(imgPickerController, animated: true, completion: nil)
    }
    
    func pullData() {
        let parameters : Parameters = ["email":CacheUser.email]
        
        AF.request("\(NetworkManager.url)/api/user",method: .get,parameters: parameters).responseJSON { [self] response in
            
            print("response: \(response)")
            
            if let data = response.data {
                do {
                    let answer = try JSONDecoder().decode(User.self, from: data)
                    
                    txtNickName.text = answer.username
                    
                    if answer.pp == "\(NetworkManager.url)/pp" {
                        
                    }else{
                        profilImage.sd_setImage(with: URL(string: answer.pp ?? ""), completed: nil)
                    }
                    
                }catch{
                    print("Error Localized Description \(error.localizedDescription)")
                }
            }
            
        }
    }
    
    @objc func actionNext() {
        if txtNickName.text == "" {
            makeAlert(tittle: "Hata", message: "Kullanıcı adı kısmını boş bırakmayınız")
            return
        }
        
        loadingView.isHidden = false
        if profilImage.image == UIImage(named: "emojiman") {
            let parameters : Parameters = ["email":CacheUser.email,
                                           "newUsername" : txtNickName.text!]
            
            AF.request("\(NetworkManager.url)/api/change-username",method: .post,parameters: parameters).responseJSON { [self] response in
                
                print("response: \(response)")
                
                if let data = response.data {
                    do {
                        let answer = try JSONDecoder().decode(SignUp.self, from: data)
                       
                        if answer.status == true {
                            loadingView.isHidden = true
                            pullData()
                            makeAlert(tittle: "Başarılı", message: "Kullanıcı adınız başarıyla güncellendi")
                        }else{
                            loadingView.isHidden = true
                            makeAlert(tittle: "Uyarı", message: answer.message ?? "")
                        }
                        
                    }catch{
                        loadingView.isHidden = true
                        makeAlert(tittle: "Error Localized Description", message: "\(error.localizedDescription)")
                    }
                }
                
            }
        }else{
            let parameters : Parameters = ["email":CacheUser.email,
                                           "newUsername" : txtNickName.text!]
            
            AF.request("\(NetworkManager.url)/api/change-username",method: .post,parameters: parameters).responseJSON { [self] response in
                
                print("response: \(response)")
                
                if let data = response.data {
                    do {
                        let answer = try JSONDecoder().decode(SignUp.self, from: data)
                       
                        if answer.status == true {
                            let parametersPhoto = ["email" : CacheUser.email
                            ]
                            
                            AF.upload(multipartFormData: { multipartFormData in
                                
                                for (key, value) in parametersPhoto {
                                    multipartFormData.append(value.data(using: .utf8)!, withName: key)
                                }
                                
                                if let jpegData = self.profilImage.image!.jpegData(compressionQuality: 1.0) {
                                    multipartFormData.append(jpegData, withName: "file", fileName: "file", mimeType: ".png")
                                }
                            }, to: "\(NetworkManager.url)/api/change-pp")
                            .response { response in
                                print(response)
                                if response.response?.statusCode == 200 {
                                    print("OK. Done")
                                    loadingView.isHidden = true
                                    pullData()
                                    makeAlert(tittle: "Başarılı", message: "Profil bilgileriniz başarıyla düzenlendi")
                                }
                            }
                           
                        }else{
                            makeAlert(tittle: "Uyarı", message: answer.message ?? "")
                        }
                        
                    }catch{
                        makeAlert(tittle: "Error Localized Description", message: "\(error.localizedDescription)")
                    }
                }
                
            }
        }
        
        
        
        
        
        
    }
    
    func updateImage() {
        
    }
    

}

extension EditProfileController : UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let imgSecilen = info[.originalImage] as? UIImage
        self.profilImage.image = imgSecilen?.withRenderingMode(.alwaysOriginal)
        profilImage.layer.masksToBounds = true
        profilImage.contentMode = .scaleAspectFill
        dismiss(animated: true, completion: nil)
    }
}
