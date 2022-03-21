//
//  ShareVideoService.swift
//  SenSoyleAvrupa
//
//  Created by Ing. Ebu Celik on 21.03.22.
//

import Foundation
import Combine
import Alamofire

public protocol ShareVideoServiceProtocol {
    func shareVideo(email: String, comment: String, url: URL?) -> AnyPublisher<Int, APIError>
    func getCoinSettings() -> AnyPublisher<CoinSettingsModel, APIError>
    func getUser(email: String) -> AnyPublisher<UserModel, APIError>
}

final class ShareVideoService: ShareVideoServiceProtocol {
    func shareVideo(email: String, comment: String, url: URL?) -> AnyPublisher<Int, APIError> {
        let parameters = ["email": email, "status": comment]

        return NetworkManager.upload(endpoint: "/api/upload-vid", parameters: parameters, data: nil, url: url, mimeType: "video/mp4")
    }

    func getCoinSettings() -> AnyPublisher<CoinSettingsModel, APIError> {
        return NetworkManager.call(endpoint: "/api/coin-settings", method: .get, parameters: .init())
    }

    func getUser(email: String) -> AnyPublisher<UserModel, APIError> {
        let parameters: Parameters = ["email": email]

        return NetworkManager.call(endpoint: "/api/user", method: .get, parameters: parameters)
    }
}
