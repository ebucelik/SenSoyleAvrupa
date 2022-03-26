//
//  HomeController.swift
//  SenSoyleAvrupa
//
//  Created by ilyas abiyev on 16.04.21.
//

import UIKit
import PanModal
import GoogleMobileAds
import AppTrackingTransparency
import AdSupport
import AVFoundation
import IGListKit

class HomeController: UIViewController {

    private struct State {
        private(set) var oldVideoDataModel: [VideoDataModel]
    }

    // MARK: Properties
    private let service: SharedServiceProtocol
    private var state: State = State(oldVideoDataModel: [])
    private var prefetchedPlayer: [[String: AVPlayer]] = []
    private var interstitial: GADInterstitialAd?

    // MARK: Models
    private var videoDataModels = [VideoDataModel]()

    // MARK: Views
    private let refreshControl = UIRefreshControl()
    private lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(),
                           viewController: self,
                           workingRangeSize: 1)
    }()
    private let collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.isPagingEnabled = true
        return collectionView
    }()

    init(service: SharedServiceProtocol) {
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
            editAdMob()
        })

        pullData()

        if let cell = collectionView.visibleCells.first as? HomeCell {
            cell.homeView.playerView.player?.play()
            cell.homeView.imageViewPause.alpha = 0
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let cell = collectionView.visibleCells.first as? HomeCell {
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
        view.addSubview(collectionView)
        collectionView.addToSuperViewAnchors()
        refreshControl.addTarget(self, action: #selector(pullData), for: .valueChanged)
        collectionView.refreshControl = refreshControl

        refreshControl.anchor(top: view.topAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor, padding: .init(top: 80))

        adapter.collectionView = collectionView
        adapter.dataSource = self
    }

    @objc
    func pullData() {
        service.pullVideoData(email: CacheUser.email) { [self] videoDataModels in
            if state.oldVideoDataModel != videoDataModels {
                prefetchedPlayer.removeAll()
                state = State(oldVideoDataModel: videoDataModels)
                self.videoDataModels = videoDataModels
                self.adapter.performUpdates(animated: true)
            }

            refreshControl.endRefreshing()
        }
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
}

extension HomeController: ListAdapterDataSource {
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return videoDataModels
    }

    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        return HomeSectionController()
    }

    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return EmptyView()
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
