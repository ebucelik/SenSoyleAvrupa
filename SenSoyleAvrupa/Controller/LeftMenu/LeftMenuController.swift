//
//  LeftMenuController.swift
//  SenSoyleAvrupa
//
//  Created by ilyas abiyev on 17.04.21.
//

import UIKit
import SideMenu
import CoreData

class LeftMenuController: UITableViewController {
    
    let context = appDelegate.persistentContainer.viewContext
    
    var userArray = [UserData]()
    
    let topView : UIView = {
        let view = UIView()
        return view
    }()

    let profilImage : UIImageView = {
        let img = UIImageView(image: UIImage(named: "Character1Color1"))
        img.layer.borderColor = UIColor.customTintColor().cgColor
        img.widthAnchor.constraint(equalToConstant: 100).isActive = true
        img.heightAnchor.constraint(equalToConstant: 100).isActive = true
        img.layer.cornerRadius = 50
        img.clipsToBounds = true
        img.layer.masksToBounds = true
        img.translatesAutoresizingMaskIntoConstraints = false
        img.contentMode = .scaleAspectFit
        img.clipsToBounds = true
        img.layer.shadowColor = UIColor.white.cgColor
        img.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        img.layer.shadowRadius = 2.0
        img.layer.shadowOpacity = 0.3
        img.layer.masksToBounds = false
        return img
    }()
    
    var labelArray = ["Coin Satın Al","Mesajlar","Kullanıcı Sözleşmesi","Gizlilik Sözleşmesi","Çıkış Yap"]
    
    var imagearray = ["dollarsign.circle","message.circle.fill","lock.shield","shield.checkerboard","return"]
    
    var controller = [PurchaseCoinController(service: ViewControllerService()),
                      MessageController(),
                      TermsofServiceController(),
                      PrivacyPolicyController()]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.keyboardDismissMode = .interactive
        
        tableView.backgroundColor = .customBackgroundColor()
        
        tableView.tableFooterView = UIView()
        
        tableView.separatorColor = .customLabelColor()
        
        tableView.isScrollEnabled = false
        
        tableView.showsVerticalScrollIndicator = false
        
        topView.addSubview(profilImage)
        
        
        
       
       
       
        profilImage.centerViewAtSuperView()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = true
    }
    
    @objc func actionDismiss() {
        self.dismiss(animated: true, completion: nil)
    }
    
    //Table View
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return topView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 140
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return labelArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = labelArray[indexPath.row]
        cell.textLabel?.textColor = .customLabelColor()
        cell.imageView?.image = UIImage(systemName: imagearray[indexPath.row])
        cell.imageView?.tintColor = .customLabelColor()
        cell.separatorInset = .zero
        cell.backgroundColor = .customBackgroundColor()
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 4 {
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
        }else{
            navigationController?.pushViewController(controller[indexPath.row], animated: true)
        }
        
    }
    
}
