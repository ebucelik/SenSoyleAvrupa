//
//  MessageModel.swift
//  SenSoyleAvrupa
//
//  Created by ilyas abiyev on 25.04.21.
//

import UIKit

class MessageModel: Codable, Equatable {
    var date: String?
    var id: Int?
    var message: String?
    var user: Int?

    init(date: String, id: Int, message:String, user:Int) {
        self.date = date
        self.id = id
        self.message = message
        self.user = user
    }

    static func == (lhs: MessageModel, rhs: MessageModel) -> Bool {
        return lhs.date == rhs.date &&
        lhs.id == rhs.id &&
        lhs.message == rhs.message &&
        lhs.user == rhs.user
    }
}

class MessagesModel: Codable  {
    var status: Bool?
    var message: String?
    var data: [MessageModel]?

    init(status: Bool, message: String, data: [MessageModel]) {
        self.status = status
        self.message = message
        self.data = data
    }
}
