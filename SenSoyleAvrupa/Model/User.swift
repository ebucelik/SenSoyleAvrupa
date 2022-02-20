//
//  User.swift
//  SenSoyleAvrupa
//
//  Created by ilyas abiyev on 25.04.21.
//

import UIKit

class User: Codable {
    
    var coin: Int?
    var id: Int?
    var points: Int?
    var pp: String? // EbuCelik: This is the ProfilePicture url
    var username: String?

    init(coin: Int,id: Int,points: Int,pp: String,username: String) {
        self.coin = coin
        self.id = id
        self.points = points
        self.pp = pp
        self.username = username
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
