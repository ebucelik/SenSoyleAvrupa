//
//  LoginService.swift
//  SenSoyleAvrupa
//
//  Created by Ing. Ebu Celik on 18.03.22.
//

import Alamofire
import Combine

protocol LoginServiceProtocol {
    func login(email: String, password: String) -> AnyPublisher<SignUpModel, APIError>
}

final class LoginService: LoginServiceProtocol {
    func login(email: String, password: String) -> AnyPublisher<SignUpModel, APIError> {
        let parameters: Parameters = ["email": email, "password": password]

        return NetworkManager.call(endpoint: "/api/login", method: .get, parameters: parameters)
    }
}
