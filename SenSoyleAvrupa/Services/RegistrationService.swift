//
//  RegistrationService.swift
//  SenSoyleAvrupa
//
//  Created by Ing. Ebu Celik on 19.03.22.
//

import Alamofire
import Combine

public protocol RegistrationServiceProtocol {
    func register(username: String, email: String, password: String) -> AnyPublisher<SignUpModel, APIError>
}

final class RegistrationService: RegistrationServiceProtocol {
    func register(username: String, email: String, password: String) -> AnyPublisher<SignUpModel, APIError> {
        let parameters: Parameters = ["username": username, "email": email, "password": password]

        return NetworkManager.call(endpoint: "/api/register", method: .post, parameters: parameters)
    }
}
