//
//  ProfileService.swift
//  SenSoyleAvrupa
//
//  Created by Ing. Ebu Celik on 25.03.22.
//

import Combine
import Alamofire

public protocol ProfileServiceProtocol {
    func pullUserData(email: String) -> AnyPublisher<UserModel, APIError>
    func pullVideoData(email: String, userId: Int) -> AnyPublisher<[VideoDataModel], APIError>
}

final class ProfileService: ProfileServiceProtocol {
    func pullUserData(email: String) -> AnyPublisher<UserModel, APIError> {
        let parameters: Parameters = ["email": email]

        return NetworkManager.call(endpoint: "/api/user", method: .get, parameters: parameters)
    }

    func pullVideoData(email: String, userId: Int) -> AnyPublisher<[VideoDataModel], APIError> {
        let parameters: Parameters = ["email": email, "user": userId]

        return NetworkManager.call(endpoint: "/api/profile", method: .get, parameters: parameters)
    }
}
