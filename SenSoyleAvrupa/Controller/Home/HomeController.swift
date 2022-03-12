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
import AVFoundation

class HomeController: UIViewController {

    private struct State {
        private(set) var oldVideoDataModel: [VideoDataModel]
    }

    // MARK: Variables
    private let service: ViewControllerServiceProtocol
    private var state: State = State(oldVideoDataModel: [])
    private var prefetchedPlayer: [[String: AVPlayer]] = []
    private var interstitial: GADInterstitialAd?

    // MARK: Models
    private var videoDataModel = [VideoDataModel]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    // MARK: Views
    let tableView = UITableView()

    init(service: ViewControllerService) {
        self.service = service

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = true
        
        checkInternetConnection(completion: { [self] in
            pullData()
            editLayout()
            editTableView()
            editAdMob()
        })

        pullData()

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
        tableView.prefetchDataSource = self
    }

    func pullData() {
        service.pullVideoData(email: CacheUser.email) { [self] videoDataModels in
            if state.oldVideoDataModel != videoDataModels {
                prefetchedPlayer.removeAll()
                state = State(oldVideoDataModel: videoDataModels)
                videoDataModel = videoDataModels
            }
        }
    }
}

extension HomeController: UITableViewDelegate, UITableViewDataSource, UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videoDataModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // TODO: Show ad
        /*if (indexPath.row % 5 == 0) {
            let number = Int.random(in: 0..<2)

            if number == 0 || indexPath.row != 0 || indexPath.row != videoDataModel.count {
                let vc = ReklamController()
                vc.modalPresentationStyle = .fullScreen
                present(vc, animated: true)
            } else {
                startGoogleAdMob()
            }
        } else {
            print("configure ad cell 2")
        }*/
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeCell", for: indexPath) as! HomeCell
        let model = videoDataModel[indexPath.row]
        cell.homeView.configure(with: model)

        /// Use prefetched videos to increase the usability.
        let player = prefetchedPlayer.compactMap { $0.compactMap { $0.key == "\(indexPath.row)" ? $0.value : nil }.first }.first
        player != nil ? cell.homeView.setPlayerView(player: player) : cell.homeView.downloadVideo()

        cell.homeView.buttonProfileImageAction = { [self] in
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
        
        cell.homeView.buttonSendPoint = { [self] in
            print("Send point")
            sendPoints(email: model.email ?? "", videoId: model.id ?? 0, point: Int(cell.homeView.ratingView.labelTop.text!) ?? 0)
            cell.homeView.ratingView.ratingView.rating = 0
            cell.homeView.ratingView.labelTop.text = "0"
            cell.homeView.ratingView.isHidden = true
        }
        
        cell.homeView.buttonCommentAction = {
            print("Comment")
            let vc = CommentController()
            vc.videoid = model.id ?? 0
            vc.email = model.email ?? ""
            self.presentPanModal(vc)
        }
        
        cell.homeView.buttonSpamAction = {
            let id = model.id ?? 0
            let alert = UIAlertController(title: "Bildiri", message: "Bir sebep seçin", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Spam veya kötüye kullanım", style: .default, handler: { (_) in
                self.spamPost(type: 1, id: id)
            }))
            alert.addAction(UIAlertAction(title: "Yanıltıcı bilgi", style: .default, handler: { (_) in
                self.spamPost(type: 2, id: id)
            }))
            alert.addAction(UIAlertAction(title: "Tehlikeli kuruluşlar ve kişiler", style: .default, handler: { (_) in
                self.spamPost(type: 3, id: id)
            }))
            alert.addAction(UIAlertAction(title: "Yasadışı faaliyetler", style: .default, handler: { (_) in
                self.spamPost(type: 4, id: id)
            }))
            alert.addAction(UIAlertAction(title: "Dolandırıcılık", style: .default, handler: { (_) in
                self.spamPost(type: 5, id: id)
            }))
            alert.addAction(UIAlertAction(title: "Şiddet içeren ve sansürlenmemiş içerik", style: .default, handler: { (_) in
                self.spamPost(type: 6, id: id)
            }))
            alert.addAction(UIAlertAction(title: "Hayvan zulümü", style: .default, handler: { (_) in
                self.spamPost(type: 7, id: id)
            }))
            alert.addAction(UIAlertAction(title: "Nefret söylemi", style: .default, handler: { (_) in
                self.spamPost(type: 8, id: id)
            }))
            alert.addAction(UIAlertAction(title: "İptal et", style: .cancel))

            self.present(alert, animated: true, completion: nil)
        }
        return cell
    }
    
    func spamPost(type: Int, id: Int) {
        service.spamPost(type: type, id: id) { [self] in
            if let status = $0.status, status {
                makeAlert(title: "Başarılı", message: "Bildiriniz bizim için çok önemli. Teşekkürler")
                pullData()
            } else {
                makeAlert(title: "Hata", message: $0.message ?? "")
            }
        }
    }

    func sendPoints(email: String, videoId: Int, point: Int) {
        service.sendPoints(email: email, videoId: videoId, point: point) { [self] in
            if let status = $0.status, status {
                makeAlert(title: "Başarılı", message: "Puan verdiğiniz için teşekkürler")
                pullData()
            } else {
                makeAlert(title: "Hata", message: $0.message ?? "")
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

        homeCell.homeView.playerView.player?.play()
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // Pause the video if the cell is ended displaying
        guard let homeCell = cell as? HomeCell else { return }

        homeCell.homeView.playerView.player?.pause()
    }

    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach {
            guard let url = URL(string: "\(NetworkManager.url)/video/\(videoDataModel[$0.row].video ?? "")") else { return }

            prefetchedPlayer.appendIfNotContains(key: "\($0.row)", value: ["\($0.row)": AVPlayer(url: url)])
        }
    }
}

extension HomeController: GADFullScreenContentDelegate{
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
