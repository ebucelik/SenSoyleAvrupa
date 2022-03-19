//
//  Comment.swift
//  SenSoyleAvrupa
//
//  Created by ilyas abiyev on 27.04.21.
//

import UIKit

class CommentModel: Codable {
    var status: Bool?
    var message: String?
    var data: [CommentsModel]?

    init(status: Bool, message: String, data: [CommentsModel]) {
        self.status = status
        self.message = message
        self.data = data
    }
}

class CommentsModel: Codable {
    var id: Int?
    var comment: String?
    var user: Int?
    var video: Int?
    var date: String?
    var email: String?
    var username: String?
    var pp: String?

    init(id: Int, comment: String, user: Int, video: Int, date: String, email: String, username: String, pp: String) {
        self.id = id
        self.comment = comment
        self.user = user
        self.video = video
        self.date = date
        self.email = email
        self.username = username
        self.pp = pp
    }
}
