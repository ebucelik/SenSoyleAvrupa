//
//  Comment.swift
//  SenSoyleAvrupa
//
//  Created by ilyas abiyev on 27.04.21.
//

import UIKit

class Comment: Codable {
    var id: Int?
    var date: Int?
    var user: Int?
    var video: String?
    var comment: String?
  
   

    init(id: Int,user: Int,video: String,comment: String,date: Int) {
        self.id = id
        self.user = user
        self.video = video
        self.comment = comment
        self.date = date
      
       
    }
    
}


class ArrayComment : Codable  {
    var status : Bool?
    var message : String?
    var data : [Comment]?
   
   
    
    init(status: Bool, message: String,data: [Comment]) {
        self.status = status
        self.message = message
        self.data = data
    }
}
