//
//  EditProfileController.swift
//  SenSoyleAvrupa
//
//  Created by ilyas abiyev on 17.04.21.
//

import UIKit
import Alamofire

class EditProfileController: UIViewController {

    struct State {
        var oldUsername: String
        var oldProfilePicture: UIImage
    }

    // MARK: Variables
    private var state: State
    private let service: ViewControllerServiceProtocol

    var viewBigCircle: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.widthAnchor.constraint(equalToConstant: 180).isActive = true
        view.heightAnchor.constraint(equalToConstant: 180).isActive = true
        return view
    }()
    
    var viewSmallCircle: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.widthAnchor.constraint(equalToConstant: 60).isActive = true
        view.heightAnchor.constraint(equalToConstant: 60).isActive = true
        view.backgroundColor = .white
        return view
    }()
    
    let imageViewProfileImage: UIImageView = {
        let img = UIImageView(image: UIImage())
        img.translatesAutoresizingMaskIntoConstraints = false
        img.backgroundColor = .white
        img.widthAnchor.constraint(equalToConstant: 180).isActive = true
        img.heightAnchor.constraint(equalToConstant: 180).isActive = true
        img.layer.cornerRadius = 90
        img.clipsToBounds = true
        img.layer.masksToBounds = true
        img.contentMode = .scaleAspectFill
        return img
    }()
    
    let imageViewEdit: UIImageView = {
        let img = UIImageView(image: UIImage(systemName: "pencil.circle"))
        img.translatesAutoresizingMaskIntoConstraints = false
        img.widthAnchor.constraint(equalToConstant: 60).isActive = true
        img.heightAnchor.constraint(equalToConstant: 60).isActive = true
        img.layer.cornerRadius = 30
        img.clipsToBounds = true
        img.layer.masksToBounds = true
        img.contentMode = .scaleAspectFill
        img.tintColor = .customLabelColor()
        return img
    }()
    
    let buttonSubmit: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Güncelle", for: .normal)
        btn.backgroundColor = .customTintColor()
        btn.titleLabel?.tintColor = .white
        btn.titleLabel?.font = .systemFont(ofSize: 17, weight: .heavy)
        btn.layer.cornerRadius = 15
        btn.heightAnchor.constraint(equalToConstant: 50).isActive = true
        btn.addTarget(self, action: #selector(updateProfile), for: .touchUpInside)
        return btn
    }()

    let labelUsername: UILabel = {
        let lbl = UILabel()
        lbl.text = "Kullanıcı adınız"
        lbl.textColor = .black
        lbl.font = .boldSystemFont(ofSize: 15)
        return lbl
    }()
    
    let textFieldUsername : UITextField = {
        let textField = CustomTextField()
        textField.backgroundColor = .customBackgroundColor()
        textField.layer.cornerRadius = 5
        textField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        textField.textColor = .black
        return textField
    }()

    let loadingView = LoadingView()

    init(service: ViewControllerServiceProtocol) {
        self.state = State(oldUsername: textFieldUsername.text!, oldProfilePicture: imageViewProfileImage.image ?? UIImage())
        self.service = service

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        pullData()
        
        navigationController?.navigationBar.isHidden = false
        
        if !CheckInternet.Connection() {
            let vc = NoInternetController(completion: { self.pullData() })
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
        
        let stackView = UIStackView(arrangedSubviews: [labelUsername,textFieldUsername,buttonSubmit])
        stackView.axis = .vertical
        stackView.spacing = 10
        
        view.addSubview(viewBigCircle)
        
        viewBigCircle.addSubview(imageViewProfileImage)
        viewBigCircle.addSubview(viewSmallCircle)
        viewSmallCircle.addSubview(imageViewEdit)
        
        view.addSubview(stackView)
        view.addSubview(loadingView)

        viewBigCircle.anchor(top: view.safeAreaLayoutGuide.topAnchor, padding: .init(top: 20, left: 0, bottom: 0, right: 0))
        viewBigCircle.centerXAtSuperView()
        
        imageViewProfileImage.addToSuperViewAnchors()
        
        imageViewEdit.anchor(top: viewSmallCircle.topAnchor, bottom: viewSmallCircle.bottomAnchor, leading: viewSmallCircle.leadingAnchor, trailing: viewSmallCircle.trailingAnchor)
        
        stackView.anchor(top: imageViewProfileImage.bottomAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor,padding: .init(top: 10, left: 20, bottom: 0, right: 20))

        loadingView.addToSuperViewAnchors()
        
        loadingView.isHidden = true
        
        let gestureEdit = UITapGestureRecognizer(target: self, action: #selector(selectProfileImage))
        viewSmallCircle.addGestureRecognizer(gestureEdit)
        
        let (hMult, vMult) = computeMultipliers(angle: 45)
        
        NSLayoutConstraint(item: viewSmallCircle, attribute: .centerX, relatedBy: .equal, toItem: viewBigCircle, attribute: .trailing, multiplier: hMult, constant: 0).isActive = true
        NSLayoutConstraint(item: viewSmallCircle, attribute: .centerY, relatedBy: .equal, toItem: viewBigCircle, attribute: .bottom, multiplier: vMult, constant: 0).isActive = true
    }
    
    func computeMultipliers(angle: CGFloat) -> (CGFloat, CGFloat) {
        let radians = angle * .pi / 180
        
        let h = (1.0 + cos(radians)) / 2
        let v = (1.0 - sin(radians)) / 2
        
        return (h, v)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        viewBigCircle.layer.cornerRadius = 0.5 * viewBigCircle.frame.height
        
        viewSmallCircle.layoutIfNeeded()
        viewSmallCircle.layer.cornerRadius = 0.5 * viewSmallCircle.frame.height
        
    }
    
    @objc func selectProfileImage() {
        let imgPickerController = UIImagePickerController()
        imgPickerController.delegate = self
        present(imgPickerController, animated: true)
    }
    
    func pullData() {
        service.pullUserData(email: CacheUser.email) { [self] userModel in
            textFieldUsername.text = userModel.username

            if userModel.pp != "\(NetworkManager.url)/pp" {
                imageViewProfileImage.sd_setImage(with: URL(string: userModel.pp ?? ""), completed: nil)
            }

            state = State(oldUsername: userModel.username ?? "", oldProfilePicture: imageViewProfileImage.image ?? UIImage())
        }
    }
    
    @objc func updateProfile() {
        let username = textFieldUsername.text ?? ""
        let profilePicture = imageViewProfileImage.image ?? UIImage()

        if username.isEmpty {
            makeAlert(title: "Hata", message: "Kullanıcı adı kısmını boş bırakmayınız")
            return
        }
        
        loadingView.isHidden = false

        if state.oldUsername != username {
            service.changeUsername(email: CacheUser.email, username: username, onError: {
                self.loadingView.isHidden = true
            }) { [self] signUpModel in
                if let status = signUpModel.status, status {
                    state.oldUsername = username
                    pullData()
                    makeAlert(title: "Başarılı", message: "Kullanıcı adınız başarıyla güncellendi")
                } else {
                    makeAlert(title: "Uyarı", message: signUpModel.message ?? "")
                }

                loadingView.isHidden = true
            }
        } else if state.oldProfilePicture != profilePicture {
            let parametersPhoto = ["email": CacheUser.email]

            AF.upload(multipartFormData: { multipartFormData in
                for (key, value) in parametersPhoto {
                    multipartFormData.append(value.data(using: .utf8)!, withName: key)
                }

                if let jpegData = self.imageViewProfileImage.image!.jpegData(compressionQuality: 1.0) {
                    multipartFormData.append(jpegData, withName: "file", fileName: "file", mimeType: ".png")
                }
            }, to: "\(NetworkManager.url)/api/change-pp").response { [self] response in
                print(response)
                if response.response?.statusCode == 200 {
                    print("OK. Done")
                    loadingView.isHidden = true
                    pullData()
                    makeAlert(title: "Başarılı", message: "Profil resminiz başarıyla düzenlendi")
                } else {
                    loadingView.isHidden = true
                    makeAlert(title: "Uyarı", message: "Profil resminiz düzenmede hata olustu")
                }
            }
        } else {
            loadingView.isHidden = true
            makeAlert(title: "Uyarı", message: "Profiliniz'de bi degisim fark edilmedi")
        }
    }
}

extension EditProfileController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let selectedImage = info[.originalImage] as? UIImage
        self.imageViewProfileImage.image = selectedImage?.withRenderingMode(.alwaysOriginal)
        imageViewProfileImage.layer.masksToBounds = true
        imageViewProfileImage.contentMode = .scaleAspectFill
        dismiss(animated: true)
    }
}
