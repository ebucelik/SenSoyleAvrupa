//
//  PurchaseCoinController.swift
//  SenSoyleAvrupa
//
//  Created by ilyas abiyev on 17.04.21.
//

import UIKit
import Alamofire

extension Notification.Name {
    static let notificationName = Notification.Name("Coin")
}

class PurchaseCoinController: UIViewController {

    struct State {
        var initialVideoPurchased: Bool
    }

    // MARK: Variables
    private var state: State
    private let service: ViewControllerServiceProtocol
    private let userDefaultsKey = "initialVideoPurchased"
    private var purchaseModels = [PurchaseModel]()
    private var purchasedCoins = 0

    // MARK: Views
    let buttonDismiss: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        btn.tintColor = .customTintColor()
        btn.heightAnchor.constraint(equalToConstant: 36).isActive = true
        btn.widthAnchor.constraint(equalToConstant: 36).isActive = true
        btn.addTarget(self, action: #selector(dismissViewController), for: .touchUpInside)
        btn.layer.cornerRadius = 18
        btn.backgroundColor = .customBackgroundColor()
        return btn
    }()
    
    let labelCoinsTitle: UILabel = {
        let lbl = UILabel()
        lbl.text = "Coin Bakiyeniz:"
        lbl.textColor = .black
        lbl.font = .boldSystemFont(ofSize: 15)
        return lbl
    }()
    
    let labelCoins: UILabel = {
        let lbl = UILabel()
        lbl.text = ""
        lbl.textColor = .customTintColor()
        lbl.textAlignment = .left
        lbl.font = .systemFont(ofSize: 30, weight: .heavy)
        lbl.numberOfLines = 0
        return lbl
    }()
    
    let labelBuyCoin: UILabel = {
        let lbl = UILabel()
        lbl.text = "Coin paketi"
        lbl.textColor = .black
        lbl.font = .boldSystemFont(ofSize: 15)
        lbl.textAlignment = .left
        return lbl
    }()
    
    let purchaseView: PurchaseView = {
        let purchaseView = PurchaseView()
        purchaseView.isUserInteractionEnabled = true
        return purchaseView
    }()

    let loadingView: LoadingView = {
        let loadingView = LoadingView()
        loadingView.isHidden = true
        return loadingView
    }()

    init(service: ViewControllerService) {
        self.state = State(initialVideoPurchased: false)
        self.service = service

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let initialVideoPurchased = UserDefaults.standard.object(forKey: userDefaultsKey) as? Bool {
            state = State(initialVideoPurchased: initialVideoPurchased)
        }

        pullData()

        setupView()

        setupPurchaseView()
    }
    
    func setupView() {
        title = "Satın Al"
        view.backgroundColor = .white
        
        let stackView = UIStackView(arrangedSubviews: [labelCoinsTitle, labelCoins, labelBuyCoin, purchaseView])
        stackView.axis = .vertical
        stackView.spacing = 10
        
        view.addSubview(buttonDismiss)
        view.addSubview(stackView)
        view.addSubview(loadingView)
        
        buttonDismiss.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, padding: .init(top: 20, left: 20, bottom: 0, right: 0))

        stackView.anchor(top: buttonDismiss.bottomAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor, padding: .init(top: 20, left: 20, bottom: 0, right: 20))

        loadingView.addToSuperViewAnchors()
        
        purchaseModels.append(PurchaseModel(coin: 10, price: 9.99, handler: {
            self.loadingView.isHidden = false

            IAPManager.shared.purchase(product: .diamond_10_initial, completion: {
                self.state = State(initialVideoPurchased: true)
                UserDefaults.standard.set(true, forKey: self.userDefaultsKey)
            }, purchaseCanceled: {
                self.loadingView.isHidden = true
            })
        }))

        purchaseModels.append(PurchaseModel(coin: 10, price: 4.99, handler: {
            self.loadingView.isHidden = false

            IAPManager.shared.purchase(product: .diamond_10, purchaseCanceled: {
                self.loadingView.isHidden = true
            })
        }))
        
        NotificationCenter.default.addObserver(self, selector: #selector(savePurchasedCoins), name: .notificationName, object: nil)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(purchaseViewSelected))
        purchaseView.addGestureRecognizer(tapGesture)
    }

    func setupPurchaseView() {
        let purchaseModel = purchaseModels[state.initialVideoPurchased ? 1 : 0]
        purchaseView.configure(model: purchaseModel)
    }

    func pullData() {
        service.pullUserData(email: CacheUser.email) {
            self.labelCoins.text = "\($0.coin ?? 0)"
            self.loadingView.isHidden = true
        }
    }

    @objc func dismissViewController() {
        navigationController?.popViewController(animated: true)
    }

    @objc func purchaseViewSelected() {
        let purchaseModel = purchaseModels[state.initialVideoPurchased ? 1 : 0]
        purchasedCoins = purchaseModel.coin
        purchaseModel.handler()
    }
    
    @objc func savePurchasedCoins() {
        print("Purchased Coins: \(purchasedCoins)")

        let parameters: Parameters = ["email": CacheUser.email,
                                      "coin": purchasedCoins]

        NetworkManager.call(endpoint: "/api/order", method: .post, parameters: parameters) { (result: Result<SignUpModel, Error>) in
            switch result {
            case let .failure(error):
                print("Network request error: \(error)")
                self.loadingView.isHidden = true
            case let .success(signUpModel):
                if let status = signUpModel.status, status {
                    self.pullData()
                    self.setupPurchaseView()
                } else {
                    self.loadingView.isHidden = true
                    self.makeAlert(title: "Hata", message: "Coin alme işlemi yaparken bir hata oluştu: \(signUpModel.message ?? "")")
                }
            }
        }
    }
}
