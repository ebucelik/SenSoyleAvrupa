//
//  PurchaseModel.swift
//  SenSoyleAvrupa
//
//  Created by Ing. Ebu Celik on 05.03.22.
//

import Foundation

struct PurchaseModel {
    var coin: Int
    var price: Float
    var handler: (() -> Void)
}
