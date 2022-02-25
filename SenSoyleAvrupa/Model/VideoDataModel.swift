//
//  VideoDataModel.swift
//  SenSoyleAvrupa
//
//  Created by ilyas abiyev on 26.04.21.
//

import UIKit

class VideoDataModel: Codable {
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
    var isPlaying: Bool? // TODO: Remove this variable when not needed
   

    init(comment: Int,date: String,email: String,id: Int,likes: Int,pp: String,spam: Int,status: String,user: Int,username: String,video: String, isPlaying: Bool = false) {
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
        self.isPlaying = isPlaying
        
       
       
    }
    
}

