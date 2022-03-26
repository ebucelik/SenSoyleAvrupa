//
//  SignUpModel.swift
//  SenSoyleAvrupa
//
//  Created by Ing. Ebu Celik on 05.03.22.
//

import UIKit

public class SignUpModel: Codable, Equatable {
    var status: Bool?
    var message: String?

    init(status: Bool, message: String) {
        self.status = status
        self.message = message
    }

    public static func == (lhs: SignUpModel, rhs: SignUpModel) -> Bool {
        return lhs.status == rhs.status &&
        lhs.message == rhs.message
    }
}
