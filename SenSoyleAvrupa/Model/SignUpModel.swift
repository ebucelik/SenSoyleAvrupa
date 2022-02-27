//
//  SignUpModel.swift
//  SenSoyleAvrupa
//
//  Created by ilyas abiyev on 19.04.21.
//

import UIKit


class SignUpModel: Codable {
    var status: Bool?
    var message: String?

    init(status: Bool, message: String) {
        self.status = status
        self.message = message
    }
    
}
