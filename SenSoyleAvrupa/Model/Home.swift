//
//  Home.swift
//  SenSoyleAvrupa
//
//  Created by ilyas abiyev on 26.04.21.
//

import UIKit

class Home: Codable {
    var comment: Int?
    var date: String?
    var email: String?
    var id: Int?
    var likes: Int?
    var pp: String?
    var spam: Int?
    var status: String?
    var user: Int?
    var username: String?
    var video: String?
   

    init(comment: Int,date: String,email: String,id: Int,likes: Int,pp: String,spam: Int,status: String,user: Int,username: String,video: String) {
        self.comment = comment
        self.date = date
        self.email = email
        self.id = id
        self.likes = likes
        self.pp = pp
        self.spam = spam
        self.status = status
        self.user = user
        self.username = username
        self.video = video
        
        
       
       
    }
    
}

