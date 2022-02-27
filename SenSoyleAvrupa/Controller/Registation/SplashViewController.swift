//
//  SplashViewController.swift
//  SenSoyleAvrupa
//
//  Created by ilyas abiyev on 13.04.21.
//

import UIKit
import CoreData
import Alamofire

class SplashViewController: UIViewController {
    
    let context = appDelegate.persistentContainer.viewContext
    
    var userArray = [UserData]()
    
    var email = ""
    
    lazy var imgLogo : UIImageView = {
        let img = UIImageView(image: UIImage(named: "Character1Color1"))
        img.widthAnchor.constraint(equalToConstant: view.frame.width / 1.5).isActive = true
        img.heightAnchor.constraint(equalToConstant: view.frame.width / 1.5).isActive = true
        img.clipsToBounds = false
        return img
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = true
        
        if !CheckInternet.Connection() {
            let vc = NoInternetController()
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        editLayout()
        
        pullData()
    }
    
    func editLayout() {
        view.backgroundColor = .white
        
        view.addSubview(imgLogo)
        
        imgLogo.centerViewAtSuperView()
    }
    
    func pullData() {
        do{
            userArray = try context.fetch(UserData.fetchRequest())
        }catch{
            print("Error Pull Data")
        }
        
        for k in userArray{
            email = k.email ?? ""
        }
        
        if email == "" {
            perform(#selector(actionWelcomePage), with: nil,afterDelay: 1)
        }else{
            let parameters : Parameters = ["email":email]
            
            AF.request("\(NetworkManager.url)/api/user",method: .get,parameters: parameters).responseJSON { [self] response in

                print("response: \(response)")

                if let data = response.data {
                    do {
                        let answer = try JSONDecoder().decode(UserModel.self, from: data)

                        print("splash email \(email)")
                        CacheUser.email = email
                        if answer.pp == "\(NetworkManager.url)/pp" {
                            perform(#selector(actionChooseProfilImage), with: nil, afterDelay: 1)
                        } else {
                            perform(#selector(actionTabBar), with: nil, afterDelay: 1)
                        }
                    }catch{
                        makeAlert(title: "Error Localized Description", message: "\(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    @objc func actionTabBar() {
        let vc = CustomTabbar()
        let navigationVC = UINavigationController(rootViewController: vc)
        navigationVC.modalPresentationStyle = .fullScreen
        present(navigationVC, animated: true, completion: nil)
    }
    
    @objc func actionWelcomePage() {
        let vc = WelcomeChooseController()
        let navigationVC = UINavigationController(rootViewController: vc)
        navigationVC.modalPresentationStyle = .fullScreen
        present(navigationVC, animated: true, completion: nil)
    }
    
    @objc func actionChooseProfilImage() {
        let vc = ChooseProfileImageController()
        let navigationVC = UINavigationController(rootViewController: vc)
        navigationVC.modalPresentationStyle = .fullScreen
        present(navigationVC, animated: true, completion: nil)
    }
    
}
