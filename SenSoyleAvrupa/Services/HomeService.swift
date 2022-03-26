//
//  HomeService.swift
//  SenSoyleAvrupa
//
//  Created by Ing. Ebu Celik on 26.03.22.
//

import Combine
import Alamofire

public protocol HomeServiceProtocol {
    func loadVideoData(email: String) -> AnyPublisher<[VideoDataModel], APIError>
    func sendSpam(videoId: Int, type: Int) -> AnyPublisher<SignUpModel, APIError>
    func sendPoints(email: String, videoId: Int, point: Int) -> AnyPublisher<SignUpModel, APIError>
}

final class HomeService: HomeServiceProtocol {
    func loadVideoData(email: String) -> AnyPublisher<[VideoDataModel], APIError> {
        let parameters: Parameters = ["email": email]

        return NetworkManager.call(endpoint: "/api/videos", method: .get, parameters: parameters)
    }

    func sendSpam(videoId: Int, type: Int) -> AnyPublisher<SignUpModel, APIError> {
        let parameters: Parameters = ["email": CacheUser.email,
                                      "video": videoId,
                                      "type": type]

        return NetworkManager.call(endpoint: "/api/spam", method: .post, parameters: parameters)
    }

    func sendPoints(email: String, videoId: Int, point: Int) -> AnyPublisher<SignUpModel, APIError> {
        let parameters: Parameters = ["email": email,
                                      "video": videoId,
                                      "point": point]

        return NetworkManager.call(endpoint: "/api/like-vid", method: .post, parameters: parameters)
    }
}
