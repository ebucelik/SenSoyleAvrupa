//
//  UserModel.swift
//  SenSoyleAvrupa
//
//  Created by Ing. Ebu Celik on 05.03.22.
//

import UIKit

public class UserModel: Codable, Equatable {
    var coin: Int?
    var id: Int?
    var points: Int?
    var pp: String? // EbuCelik: This is the ProfilePicture url
    var username: String?

    init(coin: Int, id: Int, points: Int, pp: String, username: String) {
        self.coin = coin
        self.id = id
        self.points = points
        self.pp = pp
        self.username = username
    }

    public static func == (lhs: UserModel, rhs: UserModel) -> Bool {
        return lhs.coin == rhs.coin &&
        lhs.id == rhs.id &&
        lhs.points == rhs.points &&
        lhs.pp == rhs.pp &&
        lhs.username == rhs.username
    }
}

public class CacheUser {
    static var email = ""
    static var coin = 0
    static var id = 0
    static var pp = ""
    static var username = ""
    static var points = 0
}
