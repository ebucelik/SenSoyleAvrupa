//
//  IAPManager.swift
//  SenSoyleAvrupa
//
//  Created by Ing. Ebu Celik on 11.03.22.
//

import Foundation
import StoreKit

final class IAPManager: NSObject {
    static let shared = IAPManager()
    private var products = [SKProduct]()
    private var completion: (() -> Void)?
    private var purchaseCanceled: (() -> Void)?

    fileprivate override init() {}

    enum Product: String, CaseIterable {
        case diamond_10_initial = "com.ebucelik.SenSoyleAvrupa.diamond10Initial"
        case diamond_10 = "com.ebucelik.SenSoyleAvrupa.diamond10"
    }

    public func fetchProducts() {
        let request = SKProductsRequest(productIdentifiers: Set(Product.allCases.compactMap { $0.rawValue }))
        request.delegate = self
        request.start()
    }

    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print("Products returned : \(response.products.count)")
        self.products = response.products
    }
}

extension IAPManager: SKProductsRequestDelegate {
    public func purchase(product: Product, completion: (() -> Void)? = nil, purchaseCanceled: (() -> Void)? = nil) {
        self.completion = completion
        self.purchaseCanceled = purchaseCanceled

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
}

extension IAPManager: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        transactions.forEach({
            switch $0.transactionState {
            case .purchasing:
                print("purchasing")
                break
            case .purchased:
                print("purchased")

                // MARK: We want to finish the transaction and remove the observer.
                finishTransaction($0)

                guard let completion = completion else { break }
                completion()

                break
            case .failed, .deferred:
                finishTransaction($0)

                guard let purchaseCanceled = purchaseCanceled else { break }
                purchaseCanceled()

                break
            case .restored:
                finishTransaction($0)

                guard let purchaseCanceled = purchaseCanceled else { break }
                purchaseCanceled()

                break
            @unknown default:
                break
            }
        })
    }

    func finishTransaction(_ transaction: SKPaymentTransaction) {
        SKPaymentQueue.default().finishTransaction(transaction)
        SKPaymentQueue.default().remove(self)
    }
}
