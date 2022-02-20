//
//  Puan.swift
//  SenSoyleAvrupa
//
//  Created by ilyas abiyev on 27.04.21.
//

import UIKit


class Puan: Codable {
    
    var avarage: Int?
    var total: Int?
    

    init(avarage: Int,total: Int) {
        self.avarage = avarage
        self.total = total
       
    }
    
}
class ArrayPuan : Codable  {
    var status : Bool?
    var message : String?
    var data : [Puan]?
   
   
    
    init(status: Bool, message: String,data: [Puan]) {
        self.status = status
        self.message = message
        self.data = data
    }
}
