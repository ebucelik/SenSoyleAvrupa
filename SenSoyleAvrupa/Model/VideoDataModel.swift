//
//  VideoDataModel.swift
//  SenSoyleAvrupa
//
//  Created by Ing. Ebu Celik on 05.03.22.
//

import UIKit
import IGListKit

public class VideoDataModel: Codable, Equatable {
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

    init(comment: Int, date: String, email: String, id: Int, likes: Int, pp: String, spam: Int, status: String, user: Int, username: String, video: String) {
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

    public static func == (lhs: VideoDataModel, rhs: VideoDataModel) -> Bool {
        return lhs.comment == rhs.comment &&
        lhs.date == rhs.date &&
        lhs.email == rhs.email &&
        lhs.id == rhs.id &&
        lhs.likes == rhs.likes &&
        lhs.pp == rhs.pp &&
        lhs.spam == rhs.spam &&
        lhs.status == rhs.status &&
        lhs.user == rhs.user &&
        lhs.username == rhs.username &&
        lhs.video == rhs.video
    }
}

extension VideoDataModel: ListDiffable {
    public func diffIdentifier() -> NSObjectProtocol {
        return (self.id ?? 0) as NSObjectProtocol
    }

    public func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        if let object = object as? VideoDataModel {
            return self == object
        }

        return false
    }
}
