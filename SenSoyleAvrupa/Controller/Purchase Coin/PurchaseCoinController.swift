//
//  PurchaseCoinController.swift
//  SenSoyleAvrupa
//
//  Created by ilyas abiyev on 17.04.21.
//

import UIKit
import Alamofire
import StoreKit

extension Notification.Name {
    static let notificationName = Notification.Name("Coin")
}

class PurchaseCoinController: UIViewController {
    
    
    let btnLeft : UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        btn.tintColor = .customTintColor()
        btn.heightAnchor.constraint(equalToConstant: 36).isActive = true
        btn.widthAnchor.constraint(equalToConstant: 36).isActive = true
        btn.addTarget(self, action: #selector(actionLeft), for: .touchUpInside)
        btn.layer.cornerRadius = 18
        btn.backgroundColor = .customBackgorundButton()
        return btn
    }()
    
    let lblTop : UILabel = {
        let lbl = UILabel()
        lbl.text = "Coin Bakiyeniz:"
        lbl.textColor = .customLabelColor()
        lbl.textAlignment = .left
        lbl.font = .systemFont(ofSize: 30, weight: .heavy)
        lbl.numberOfLines = 0
        return lbl
    }()
    
    let lblMyCoin : UILabel = {
        let lbl = UILabel()
        lbl.text = "Coin Bakiyeniz:"
        lbl.textColor = .black
        lbl.font = .boldSystemFont(ofSize: 15)
        return lbl
    }()
    
    let lblMyCoinCount : UILabel = {
        let lbl = UILabel()
        lbl.text = ""
        lbl.textColor = .customTintColor()
        lbl.textAlignment = .left
        lbl.font = .systemFont(ofSize: 30, weight: .heavy)
        lbl.numberOfLines = 0
        return lbl
    }()
    
    let lblBuyCoin : UILabel = {
        let lbl = UILabel()
        lbl.text = "Coin paketleri"
        lbl.textColor = .black
        lbl.font = .boldSystemFont(ofSize: 15)
        lbl.textAlignment = .left
        return lbl
    }()
    
      let collectionView : UICollectionView = {
          let layout = UICollectionViewFlowLayout()
          layout.scrollDirection = .vertical
          let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
          cv.translatesAutoresizingMaskIntoConstraints = false
          cv.backgroundColor = .white
          return cv
      }()
    
    var purchaseArray = [Purchase]()
    
 
    var indexCoin = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        pullData()

        editLayout()
        
        collectionViewEdit()
    }
    
    func editLayout() {
        title = "Satın Al"
        view.backgroundColor = .white
        
       let stackView = UIStackView(arrangedSubviews: [lblMyCoin,lblMyCoinCount,lblBuyCoin,collectionView])
        stackView.axis = .vertical
        stackView.spacing = 10
        
        view.addSubview(btnLeft)
        
        view.addSubview(stackView)
        
        btnLeft.anchor(top: view.safeAreaLayoutGuide.topAnchor, bottom: nil, leading: view.leadingAnchor, trailing: nil,padding: .init(top: 20, left: 20, bottom: 0, right: 0))
        
        
        stackView.anchor(top: btnLeft.bottomAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor,padding: .init(top: 20, left: 20, bottom: 0, right: 20))
        
        purchaseArray.append(Purchase(coin: 100, price: 10,handler: {
            IAPManager.shared.purchase(product: .diamond_100)
        }))
        purchaseArray.append(Purchase(coin: 200, price: 15,handler: {
            IAPManager.shared.purchase(product: .diamond_200)
        }))
        
        NotificationCenter.default.addObserver(self, selector: #selector(saveDateCoin), name: .notificationName, object: nil)
    }
    
    func collectionViewEdit() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(UINib(nibName: "PurchaseCell", bundle: nil), forCellWithReuseIdentifier: "PurchaseCell")
        collectionView.showsVerticalScrollIndicator = false
        
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = CGSize(width: view.frame.size.width / 1.2, height: view.frame.size.width / 4.0)
            layout.minimumLineSpacing = 20
            layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        }
        
    }
    
    @objc func actionLeft() {
        navigationController?.popViewController(animated: true)
    }
    
    func pullData() {
        let parameters : Parameters = ["email":CacheUser.email]
        
        AF.request("\(NetworkManager.url)/api/user",method: .get,parameters: parameters).responseJSON { [self] response in
            
            print("response: \(response)")
            
            if let data = response.data {
                do {
                    let answer = try JSONDecoder().decode(UserModel.self, from: data)
                    
                    lblMyCoinCount.text = "\(answer.coin ?? 0)"
                   
                }catch{
                    print("Error Localized Description \(error.localizedDescription)")
                }
            }
            
        }
    }
    
    @objc func saveDateCoin() {
        print("Coin alindi")
        print("index coin \(indexCoin)")
        let parameters : Parameters = ["email":CacheUser.email,
                                       "coin" : indexCoin]

        AF.request("\(NetworkManager.url)/api/order",method: .post,parameters: parameters).responseJSON { [self] response in

            print("response: \(response)")
            if let data = response.data {
                do {
                    let answer = try JSONDecoder().decode(SignUpModel.self, from: data)

                    if answer.status == true {
                        pullData()
                    }else{
                        self.makeAlert(title: "Hata", message: "Coin alme işlemi yaparken bir hata oluştu: \(answer.message ?? "")")
                    }

                }catch{
                    makeAlert(title: "Error Localized Description", message: "\(error.localizedDescription)")
                }
            }

        }
    }
    
}

extension PurchaseCoinController : UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return purchaseArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PurchaseCell", for: indexPath) as! PurchaseCell
        let indexArray = purchaseArray[indexPath.row]
        cell.lblCoin.text = "\(indexArray.coin)"
        cell.lblPrice.text = "\(indexArray.price) ₺"
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let indexArray = purchaseArray[indexPath.row]
        print("did select")
        indexCoin = indexArray.coin
        indexArray.handler()
    }
    
}


struct Purchase {
    var coin : Int
    var price : Int
    var handler: (() -> Void)
}

final class IAPManager : NSObject,SKProductsRequestDelegate,SKPaymentTransactionObserver {
    static let shared = IAPManager()
    
    var products = [SKProduct]()
    
    enum Product: String,CaseIterable{
        case diamond_100
        case diamond_200
    }
    
    public func fetchProducts() {
        let request = SKProductsRequest(productIdentifiers: Set(Product.allCases.compactMap({$0.rawValue})))
        request.delegate = self
        request.start()
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print("Products returned : \(response.products.count)")
        self.products = response.products
    }
    
    public func purchase(product : Product) {
        guard SKPaymentQueue.canMakePayments() else{
            return
        }
        
        guard let storeKitProduct = products.first(where: {$0.productIdentifier == product.rawValue}) else {
            return
        }
        
        let paymentRequest = SKPayment(product: storeKitProduct)
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().add(paymentRequest)
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        transactions.forEach({
            switch $0.transactionState {
            case .purchasing:
                print("purchasing")
                break
            case .purchased:
                print("purchased")
                NotificationCenter.default.post(name: .notificationName, object: nil, userInfo: nil)
//                print("Notification gonderildi")
                break
            case .failed:
                break
            case .restored:
                break
            case .deferred:
                break
            @unknown default:
                break
            }
        })
    }
}



