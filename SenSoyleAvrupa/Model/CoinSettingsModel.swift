//
//  CoinSettingsModel.swift
//  SenSoyleAvrupa
//
//  Created by Ing. Ebu Celik on 05.03.22.
//

import UIKit

public class CoinSettingsModel: Codable, Equatable {
    var coin: Int?
    var first_coin: Int?

    init(coin: Int, first_coin: Int) {
        self.coin = coin
        self.first_coin = first_coin
    }

    public static func == (lhs: CoinSettingsModel, rhs: CoinSettingsModel) -> Bool {
        return lhs.coin == rhs.coin &&
        lhs.first_coin == rhs.first_coin
    }
}
