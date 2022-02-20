//
//  CoinCount.swift
//  SenSoyleAvrupa
//
//  Created by ilyas abiyev on 25.04.21.
//

import UIKit

class CointCount: Codable {
    
    var coin: Int?
    var first_coin: Int?
  

    init(coin: Int,first_coin: Int) {
        self.coin = coin
        self.first_coin = first_coin
       
    }
    
}
