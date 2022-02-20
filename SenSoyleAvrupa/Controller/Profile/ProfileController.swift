//
//  ProfileController.swift
//  SenSoyleAvrupa
//
//  Created by ilyas abiyev on 14.04.21.
//

import UIKit
import SideMenu
import Alamofire

class ProfileController: UIViewController {
    
    private let refreshControl = UIRefreshControl()
  
    let collectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .white
        return cv
    }()
    
    var name = ""
    var email = ""
    var videoCount = 0
    var puanCount = 0
    var cointCount = 0
    var pp = ""
    var id = 0
    
    var arrayCollectionView = [Home]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
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
        
        pullData()
        
       
        editLayot()
        
        editCollectionView()
    }
    
    func editLayot() {
        
        view.backgroundColor = .white
        
        view.addSubview(collectionView)
        
        collectionView.anchor(top: view.safeAreaLayoutGuide.topAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor,padding: .init(top: 5, left: 0, bottom: 0, right: 0))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "line.horizontal.3"), style: .done, target: self, action: #selector(actionLeftMenu))
        navigationItem.leftBarButtonItem?.tintColor = .customTintColor()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "video.badge.plus"), style: .done, target: self, action: #selector(actionAddVideo))
        navigationItem.rightBarButtonItem?.tintColor = .customTintColor()
        
    }
    
    func editCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(UINib(nibName: "ProfileVideoCell", bundle: nil), forCellWithReuseIdentifier: "ProfileVideoCell")
        
        collectionView.register(HeaderCollectionView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderCollectionView.identifer)
        
//        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
//            layout.itemSize = CGSize(width: view.frame.size.width / 1.2, height: view.frame.size.width / 2.2)
//            layout.minimumLineSpacing = 20
//            layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
//        }
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = CGSize(width: view.frame.width / 3.2, height: view.frame.width / 3.2)
            layout.minimumLineSpacing = 6
            layout.minimumInteritemSpacing = 5
            layout.sectionInset = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        }
        
        refreshControl.addTarget(self, action: #selector(didPullToRefresh(_:)), for: .valueChanged)
        collectionView.alwaysBounceVertical = true
        collectionView.refreshControl = refreshControl
    }
    
    @objc private func didPullToRefresh(_ sender: Any) {
        pullData()
        refreshControl.endRefreshing()
    }
    
    
    @objc func actionLeftMenu() {
        print("left menu")
        var menu : SideMenuNavigationController?
        menu = SideMenuNavigationController(rootViewController:LeftMenuController())
        menu?.leftSide = true
        menu?.statusBarEndAlpha = 0
        menu?.navigationController?.navigationBar.isHidden = true
        menu?.presentationStyle = .viewSlideOutMenuPartialIn
        SideMenuManager.default.leftMenuNavigationController = menu
        SideMenuManager.default.addPanGestureToPresent(toView: self.view)
        present(menu!, animated: true, completion: nil)
    }
    
    @objc func actionAddVideo() {
        let vc = ShareVideoController()
        let navigationVC = UINavigationController(rootViewController: vc)
        navigationVC.modalPresentationStyle = .fullScreen
        present(navigationVC, animated: true, completion: nil)
        //navigationController?.pushViewController(vc, animated: true)
    }
    
    func pullData() {
        let parameters : Parameters = ["email":CacheUser.email]
        
        AF.request("\(NetworkManager.url)/api/user",method: .get,parameters: parameters).responseJSON { [self] response in
            
            print("response: \(response)")
            
            if let data = response.data {
                do {
                    let answer = try JSONDecoder().decode(User.self, from: data)
                    
                    pp = answer.pp ?? ""
                    name = answer.username ?? ""
                    puanCount = answer.points ?? 0
                    cointCount = answer.coin ?? 0
                  
                     let parameters : Parameters = ["email":CacheUser.email,
                                                    "user" :  answer.id ?? 0]
                     
                     AF.request("\(NetworkManager.url)/api/profile",method: .get,parameters: parameters).responseJSON { [self] response in
                         
                         print("responseDataVideo: \(response)")
                         
                         if let data = response.data {
                             do {
                                 self.arrayCollectionView = try JSONDecoder().decode([Home].self, from: data)

                                 
                                 DispatchQueue.main.async { [self] in
                                     self.collectionView.reloadData()
                                 }
                                 
                                
                             }catch{
                                 print("Error Localized Description \(error.localizedDescription)")
                             }
                         }
                         
                     }
                    
                    
                }catch{
                    print("Error Localized Description \(error.localizedDescription)")
                }
                DispatchQueue.main.async { [self] in
                    self.collectionView.reloadData()
                }
            }
            
        }
    }
    
    
   
    
   
}


extension ProfileController : UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayCollectionView.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileVideoCell", for: indexPath) as! ProfileVideoCell
        let model = arrayCollectionView[indexPath.row]
        cell.configure(with: model)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderCollectionView.identifer, for: indexPath) as! HeaderCollectionView
        header.btnEditProfile.addTarget(self, action: #selector(actionEditProfile), for: .touchUpInside)
        
        if pp == "\(NetworkManager.url)/public/pp" {
            
        }else{
            header.imgProfile.sd_setImage(with: URL(string: pp), completed: nil)
        }
        
        header.lblCoinCount.text = "\(cointCount)"
        header.lblPuahCount.text = "\(puanCount)"
        header.lblName.text = name
        header.lblMail.text = CacheUser.email
        header.lblVideoCount.text = "\(arrayCollectionView.count)"
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.size.width, height: 200)
    }
    
    @objc func actionEditProfile() {
      let vc = EditProfileController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
