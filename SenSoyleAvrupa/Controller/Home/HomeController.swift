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
import Combine
import ComposableArchitecture

import SwiftHelper

class HomeController: UIViewController {

    // MARK: Properties
    private let store: Store<HomeState, HomeAction>
    private var viewStore: ViewStore<HomeState, HomeAction>
    private var cancellable: Set<AnyCancellable> = []

    private var interstitial: GADInterstitialAd?

    // MARK: Models
    private var videoDataModels = [VideoDataModel]()

    // MARK: Views
    private let refreshControl = UIRefreshControl()
    private lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(),
                           viewController: self,
                           workingRangeSize: 0)
    }()
    private let collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.isPagingEnabled = true
        return collectionView
    }()

    init(store: Store<HomeState, HomeAction>) {
        self.store = store
        self.viewStore = ViewStore(store)

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
            cell.homeView.playerView.playerLayer.player?.play()
            cell.homeView.imageViewPause.alpha = 0
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if let cell = collectionView.visibleCells.first as? HomeCell {
            cell.homeView.playerView.playerLayer.player?.pause()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // TODO: delete this when not needed anymore
        guard let deviceId = UIDevice.current.identifierForVendor?.uuidString else { return }
        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [deviceId]

        setupStateObservers()

        pullData()
        
        editLayout()

        editAdMob()
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

    func editAdMob() {
        let request = GADRequest()
        GADInterstitialAd.load(withAdUnitID: "ca-app-pub-3940256099942544/4411468910",
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

    func setupStateObservers() {
        viewStore.publisher.loadingVideoDataModels
            .sink {
                self.loadingVideoDataModels(state: $0)
            }
            .store(in: &cancellable)

        viewStore.publisher.videoDataModels
            .sink { _ in
                self.videoDataModelsUpdated()
            }
            .store(in: &cancellable)

        viewStore.publisher.loadingSignUpModel
            .sink {
                self.loadingSignUpModel(state: $0)
            }
            .store(in: &cancellable)

        viewStore.publisher.spamSignUpModel
            .sink { _ in
                self.spamSignUpModelUpdated()
            }
            .store(in: &cancellable)

        viewStore.publisher.pointsSignUpModel
            .sink { _ in
                self.pointsSignUpModelUpdated()
            }
            .store(in: &cancellable)
    }

    func loadingVideoDataModels(state: VideoDataModelLoadingState) {
        switch state {
        case .none, .loaded, .error:
            view.hideLoading()
            refreshControl.endRefreshing()

        case .loading, .refreshing:
            view.showLoading()
            refreshControl.beginRefreshing()
        }
    }

    func videoDataModelsUpdated() {
        guard let videoDataModels = viewStore.videoDataModels else { return }

        self.videoDataModels = videoDataModels
        adapter.performUpdates(animated: true)
    }

    func loadingSignUpModel(state: SignUpModelLoadingState) {
        switch state {
        case .none, .loaded, .error:
            view.hideLoading()

        case .loading, .refreshing:
            view.showLoading()
        }
    }

    func spamSignUpModelUpdated() {
        guard let signUpModel = viewStore.spamSignUpModel else { return }

        if let status = signUpModel.status, status {
            makeAlert(title: "Başarılı", message: "Bildiriniz bizim için çok önemli. Teşekkürler")
            pullData()
        } else {
            makeAlert(title: "Hata", message: signUpModel.message ?? "")
        }
    }

    func pointsSignUpModelUpdated() {
        guard let signUpModel = viewStore.pointsSignUpModel else { return }

        if let status = signUpModel.status, status {
            makeAlert(title: "Başarılı", message: "Puan verdiğiniz için teşekkürler")
            pullData()
        } else {
            makeAlert(title: "Hata", message: signUpModel.message ?? "")
        }
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

    @objc
    func pullData() {
        viewStore.send(.loadingVideoDataModels(email: CacheUser.email))
    }

    func spamPost(videoId: Int, type: Int) {
        viewStore.send(.sendSpam(videoId: videoId, type: type))
    }

    func sendPoints(email: String, videoId: Int, point: Int) {
        viewStore.send(.sendPoints(email: email, videoId: videoId, point: point))
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
