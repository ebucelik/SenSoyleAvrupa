//
//  VideoRealseController.swift
//  SenSoyleAvrupa
//
//  Created by ilyas abiyev on 30.04.21.
//

import UIKit
import Alamofire
import CoreData


class VideoRealseController: UIViewController {
    
    private var data = [VideoModel]()
    
    let tableView = UITableView()

    var id = 0
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = true
        
        checkInternetConnection(completion: { self.pullData() })

        if let cell = tableView.visibleCells.first as? HomeCell {
            cell.homeView.playerView.player?.play()
            cell.homeView.imageViewPause.alpha = 0
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let cell = tableView.visibleCells.first as? HomeCell {
            cell.homeView.playerView.player?.pause()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pullData()
        
        editLayout()
        
        editTableView()
        
    }
    
    func editLayout() {
        view.backgroundColor = .white
        
        view.addSubview(tableView)
        tableView.addToSuperViewAnchors()
        
    }
    
    func editTableView() {
        tableView.backgroundColor = .black
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.tableFooterView = UIView()
        tableView.isPagingEnabled = true
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "HomeCell", bundle: nil), forCellReuseIdentifier: "HomeCell")
        tableView.delegate = self
        tableView.dataSource = self
    }
    
   
    
    @objc func actionRatingViewSend() {
        print("send")
    }
    
    var arrayCollectionView = [VideoDataModel]()
    func pullData() {
        let parameters : Parameters = ["email":CacheUser.email]
        
        AF.request("\(NetworkManager.url)/api/videos", method: .get,parameters: parameters,encoding: URLEncoding.default)
            .responseJSON { response in
                print(response)
                if let data = response.data {
                    do {
                        self.arrayCollectionView = try JSONDecoder().decode([VideoDataModel].self, from: data)
                     
                        DispatchQueue.main.async {
                            
                            self.tableView.reloadData()
                            
                        }
                    }catch{
                        print("ErrrorJson \(error.localizedDescription)")
                    }
                    
                }
                
            }
        
    
    }
    
}



extension VideoRealseController:  UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayCollectionView.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeCell", for: indexPath) as! HomeCell
        let model = arrayCollectionView[indexPath.row]
        cell.homeView.configure(with: model)
        cell.homeView.buttonProfileImageAction = { [self]
            () in
            print("Go to profile account")
           
            let vc = ProfileController(userModel: UserModel(coin: 0,
                                                            id: model.id ?? 0,
                                                            points: 0,
                                                            pp: model.pp ?? "",
                                                            username: model.username ?? ""),
                                       email: model.email ?? "",
                                       service: ViewControllerService())
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        cell.homeView.buttonSendPoint = { [self]
            () in
            print()
           print("Send point")
            givePoin(ID: model.id ?? 0, point: Int(cell.homeView.ratingView.labelTop.text!) ?? 0, email: model.email ?? "")
            cell.homeView.ratingView.ratingView.rating = 0
            cell.homeView.ratingView.labelTop.text = "0"
            cell.homeView.ratingView.isHidden = true
        }
        
        cell.homeView.buttonCommentAction = {
            () in
            print("Comment")
            let vc = CommentController()
            vc.videoid = model.id ?? 0
            vc.email = model.email ?? ""
            self.presentPanModal(vc)
        }
        
        cell.homeView.buttonSpamAction = {
            () in
            self.id = model.id ?? 0
            let alert = UIAlertController(title: "Bildiri", message: "Bir sebep seçin", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Spam veya kötüye kullanım", style: .default, handler: { (_) in
                self.spamPost(type: 1)
            }))
            alert.addAction(UIAlertAction(title: "Yanıltıcı bilgi", style: .default, handler: { (_) in
                self.spamPost(type: 2)
            }))
            alert.addAction(UIAlertAction(title: "Tehlikeli kuruluşlar ve kişiler", style: .default, handler: { (_) in
                self.spamPost(type: 3)
            }))
            alert.addAction(UIAlertAction(title: "Yasadışı faaliyetler", style: .default, handler: { (_) in
                self.spamPost(type: 4)
            }))
            alert.addAction(UIAlertAction(title: "Dolandırıcılık", style: .default, handler: { (_) in
                self.spamPost(type: 5)
            }))
            alert.addAction(UIAlertAction(title: "Şiddet içeren ve sansürlenmemiş içerik", style: .default, handler: { (_) in
                self.spamPost(type: 6)
            }))
            alert.addAction(UIAlertAction(title: "Hayvan zulümü", style: .default, handler: { (_) in
                self.spamPost(type: 7)
            }))
            alert.addAction(UIAlertAction(title: "Nefret söylemi", style: .default, handler: { (_) in
                self.spamPost(type: 8)
            }))
            alert.addAction(UIAlertAction(title: "İptal et", style: .cancel))
           
            self.present(alert, animated: true, completion: nil)
        }
        return cell
    }
    
    func spamPost(type: Int) {
        let parameters : Parameters = ["email":CacheUser.email,
                                       "video":id,
                                       "type":type]
        
        AF.request("\(NetworkManager.url)/api/spam", method: .post,parameters: parameters,encoding: URLEncoding.default)
            .responseJSON { response in
                print(response)
                if let data = response.data {
                    do {
                        let answer = try JSONDecoder().decode(SignUpModel.self, from: data)
                        if answer.status == true {
                            self.makeAlert(title: "Başarılı", message: "Bildiriniz bizim için çok önemli.Teşekkürler")
                        }else{
                            self.makeAlert(title: "Hata", message: answer.message ?? "")
                        }
                    }catch{
                        print("ErrrorJson \(error.localizedDescription)")
                    }
                    
                }
                
            }
    }
    
    func givePoin(ID: Int,point:Int,email:String) {
        let parameters : Parameters = ["email":email,
            "video":ID,"point":point]
        
        AF.request("\(NetworkManager.url)/api/like-vid", method: .post,parameters: parameters,encoding: URLEncoding.default)
            .responseJSON { response in
                print(response)
                if let data = response.data {
                    do {
                        let answer = try JSONDecoder().decode(SignUpModel.self, from: data)
                        if answer.status == true {
                            self.makeAlert(title: "Başarılı", message: "Puan verdiğiniz için teşekkürler")
                        }else{
                            self.makeAlert(title: "Hata", message: answer.message ?? "")
                        }
                    }catch{
                        print("ErrrorJson \(error.localizedDescription)")
                    }
                    
                }
                
            }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.height
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // Pause the video if the cell is ended displaying
        if let cell = cell as? HomeCell {
            cell.homeView.playerView.player?.pause()
        }
    }
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
//        for indexPath in indexPaths {
//            print(indexPath.row)
//        }
    }
    
}

