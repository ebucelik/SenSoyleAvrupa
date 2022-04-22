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

    // MARK: Properties
    private var state: State
    private let service: SharedServiceProtocol
    private var onDismiss: ((Bool) -> Void)?
    private var modelDidChanged = false
    private var purchaseModels = [PurchaseModel]()
    private var purchasedCoins = 0
    static let userDefaultsInitialVideoPurchasedKey = "initialVideoPurchased"

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

    init(service: SharedServiceProtocol, onDismiss: ((Bool) -> Void)?) {
        self.state = State(initialVideoPurchased: false)
        self.service = service
        self.onDismiss = onDismiss

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let initialVideoPurchased = UserDefaults.standard.object(forKey: PurchaseCoinController.userDefaultsInitialVideoPurchasedKey) as? Bool {
            state = State(initialVideoPurchased: initialVideoPurchased)
        }

        pullData()

        setupView()

        setupPurchaseView()
    }

    override func viewDidDisappear(_ animated: Bool) {
        if let onDismiss = onDismiss {
            onDismiss(modelDidChanged)
        }
    }
    
    func setupView() {
        title = "Satın Al"
        view.backgroundColor = .white
        
        let stackView = UIStackView(arrangedSubviews: [labelCoinsTitle, labelCoins, labelBuyCoin, purchaseView])
        stackView.axis = .vertical
        stackView.spacing = 10
        
        view.addSubview(buttonDismiss)
        view.addSubview(stackView)
        
        buttonDismiss.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                             leading: view.leadingAnchor,
                             padding: .init(top: 20, left: 20, bottom: 0, right: 0))

        stackView.anchor(top: buttonDismiss.bottomAnchor,
                         leading: view.leadingAnchor,
                         trailing: view.trailingAnchor,
                         padding: .init(top: 20, left: 20, bottom: 0, right: 20))
        
        purchaseModels.append(PurchaseModel(coin: 10, price: 9.99, handler: {
            self.view.showLoading()

            IAPManager.shared.purchase(product: .diamond_10_initial, completion: {
                self.state = State(initialVideoPurchased: true)
                UserDefaults.standard.set(true, forKey: PurchaseCoinController.userDefaultsInitialVideoPurchasedKey)
                self.savePurchasedCoins()
                self.modelDidChanged = true
            }, purchaseCanceled: {
                self.view.hideLoading()
            })
        }))

        purchaseModels.append(PurchaseModel(coin: 10, price: 4.99, handler: {
            self.view.showLoading()

            IAPManager.shared.purchase(product: .diamond_10, completion: {
                self.savePurchasedCoins()
                self.modelDidChanged = true
            }, purchaseCanceled: {
                self.view.hideLoading()
            })
        }))

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
            self.view.hideLoading()
        }
    }

    func savePurchasedCoins() {
        print("Purchased Coins: \(purchasedCoins)")

        let parameters: Parameters = ["email": CacheUser.email,
                                      "coin": purchasedCoins]

        NetworkManager.call(endpoint: "/api/order", method: .post, parameters: parameters) { [self] (result: Result<SignUpModel, Error>) in
            switch result {
            case let .failure(error):
                print("Network request error: \(error)")
                view.hideLoading()
            case let .success(signUpModel):
                if let status = signUpModel.status, status {
                    pullData()
                    setupPurchaseView()
                } else {
                    view.hideLoading()
                    makeAlert(title: "Hata", message: "Coin alme işlemi yaparken bir hata oluştu: \(signUpModel.message ?? "")")
                }
            }
        }
    }

    @objc func purchaseViewSelected() {
        let purchaseModel = purchaseModels[state.initialVideoPurchased ? 1 : 0]
        purchasedCoins = purchaseModel.coin
        purchaseModel.handler()
    }
}
