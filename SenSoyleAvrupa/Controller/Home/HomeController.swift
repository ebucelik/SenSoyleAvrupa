//
//  HomeController.swift
//  SenSoyleAvrupa
//
//  Created by ilyas abiyev on 16.04.21.
//

import UIKit
import PanModal
import Alamofire
import SwiftyJSON
import GoogleMobileAds
import AppTrackingTransparency
import AdSupport

class HomeController: UIViewController {
    
    private var interstitial: GADInterstitialAd?
    
    private var data = [VideoModel]()
    
    let tableView = UITableView()

    var id = 0
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = true
        
        if !CheckInternet.Connection() {
            let vc = NoInternetController()
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true, completion: nil)
        }
        
        if let cell = tableView.visibleCells.first as? HomeCell {
            cell.player?.play()
            cell.imageViewPause.alpha = 0
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let cell = tableView.visibleCells.first as? HomeCell {
            cell.player?.pause()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // TODO: delete this when not needed anymore
        guard let deviceId = UIDevice.current.identifierForVendor?.uuidString else { return }
        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [deviceId]

        pullData()
        
        editLayout()
        
        editTableView()
        
        editAdMob()
    }
    
    func editAdMob() {
        let request = GADRequest()
        GADInterstitialAd.load(withAdUnitID:"ca-app-pub-3940256099942544/4411468910",
                               request: request,
                               completionHandler: { [self] ad, error in
            if let error = error {
                print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                return
            }
            interstitial = ad
            interstitial?.fullScreenContentDelegate = self
        })
    }
    
    func startAdmob() {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { [self] status in
                switch status {
                case .authorized:
                    // Tracking authorization dialog was shown
                    // and we are authorized
                    print("Authorized")
                    startGoogleAdMob()
                    return
                case .denied:
                    // Tracking authorization dialog was
                    // shown and permission is denied
                    print("Denied")
                    return

                case .notDetermined:
                    // Tracking authorization dialog has not been shown
                    print("Not Determined")
                case .restricted:
                    print("Restricted")
                @unknown default:
                    print("Unknown")
                }
            }
        }
    }
    
    func startGoogleAdMob() {
        if interstitial != nil {
            interstitial?.present(fromRootViewController: self)
        } else {
            print("Ad wasn't ready")
        }
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
    
    var home = [Home]()

    func pullData() {
        let parameters : Parameters = ["email": CacheUser.email]
        
        AF.request("\(NetworkManager.url)/api/videos", method: .get,parameters: parameters,encoding: URLEncoding.default).responseJSON { response in
            print(response)
            if let data = response.data {
                do {
                    self.home = try JSONDecoder().decode([Home].self, from: data)

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



extension HomeController:  UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return home.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // TODO: Show ad
        /*if (indexPath.row % 5 == 0) {
            let number = Int.random(in: 0..<2)

            if number == 0 || indexPath.row != 0 || indexPath.row  != arrayCollectionView.count{
                let vc = ReklamController()
                vc.modalPresentationStyle = .fullScreen
                present(vc, animated: true, completion: nil)
            }else{
                startGoogleAdMob()
            }
        } else {
            print("configure ad cell 2")
        }*/
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeCell", for: indexPath) as! HomeCell
        let model = home[indexPath.row]
        cell.configure(with: model)
        cell.buttonProfileImageAction = { [self]
            () in
            print("Go to profile account")

            let vc = OtherProfileController()
            vc.id = model.id ?? 0
            vc.email = model.email ?? ""
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        cell.buttonSendPoint = { [self]
            () in
            print()
            print("Send point")
            givePoin(ID: model.id ?? 0, point: Int(cell.ratingView.labelTop.text!) ?? 0, email: model.email ?? "")
            cell.ratingView.ratingView.rating = 0
            cell.ratingView.labelTop.text = "0"
            cell.ratingView.isHidden = true
        }
        
        cell.buttonCommentAction = {
            () in
            print("Comment")
            let vc = CommentController()
            vc.videoid = model.id ?? 0
            vc.email = model.email ?? ""
            self.presentPanModal(vc)
        }
        
        cell.buttonSpamAction = {
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
                        let answer = try JSONDecoder().decode(SignUp.self, from: data)
                        if answer.status == true {
                            self.makeAlert(tittle: "Başarılı", message: "Bildiriniz bizim için çok önemli.Teşekkürler")
                        }else{
                            self.makeAlert(tittle: "Hata", message: answer.message ?? "")
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
                        let answer = try JSONDecoder().decode(SignUp.self, from: data)
                        if answer.status == true {
                            self.makeAlert(tittle: "Başarılı", message: "Puan verdiğiniz için teşekkürler")
                        }else{
                            self.makeAlert(tittle: "Hata", message: answer.message ?? "")
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
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // If the cell is the first cell in the tableview, the queuePlayer automatically starts.
        // If the cell will be displayed, pause the video until the drag on the scroll view is ended
        guard let homeCell = cell as? HomeCell else { return }

        homeCell.player?.play()
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // Pause the video if the cell is ended displaying
        guard let homeCell = cell as? HomeCell else { return }

        homeCell.player?.pause()
    }
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        //        for indexPath in indexPaths {
        //            print(indexPath.row)
        //        }
    }
}


extension HomeController : GADFullScreenContentDelegate{
    /// Tells the delegate that the ad failed to present full screen content.
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Ad did fail to present full screen content.")
    }

    /// Tells the delegate that the ad presented full screen content.
    func adDidPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad did present full screen content.")
    }

    /// Tells the delegate that the ad dismissed full screen content.
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad did dismiss full screen content.")
    }
}
