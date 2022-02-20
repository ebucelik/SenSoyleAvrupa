//
//  Message.swift
//  SenSoyleAvrupa
//
//  Created by ilyas abiyev on 25.04.21.
//

import UIKit


class Message: Codable {
    
    var date: String?
    var id: Int?
    var message: String?
    var user: Int?
  

    init(date: String,id: Int,message:String,user:Int) {
        self.date = date
        self.id = id
        self.message = message
        self.user = user
       
    }
    
}
class ArrayMessage : Codable  {
    var status : Bool?
    var message : String?
    var data : [Message]?
   
   
    
    init(status: Bool, message: String,data: [Message]) {
        self.status = status
        self.message = message
        self.data = data
    }
}
