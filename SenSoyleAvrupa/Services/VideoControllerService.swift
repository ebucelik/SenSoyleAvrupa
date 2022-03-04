//
//  VideoControllerService.swift
//  SenSoyleAvrupa
//
//  Created by Ing. Ebu Celik on 04.03.22.
//

import Foundation
import Alamofire

public protocol VideoControllerServiceProtocol {
    func pullVideoData(email: String, block: @escaping ([VideoDataModel]) -> Void)
    func pullProfileData(email: String, block: @escaping ([VideoDataModel]) -> Void)
    func sendPoints(email: String, videoId: Int, point: Int, block: @escaping (SignUpModel) -> Void)
    func spamPost(type: Int, id: Int, block: @escaping (SignUpModel) -> Void)
}

public final class VideoControllerService: VideoControllerServiceProtocol {

    public func pullVideoData(email: String, block: @escaping ([VideoDataModel]) -> Void) {
        let parameters: Parameters = ["email": email]

        NetworkManager.call(endpoint: "/api/videos", method: .get, parameters: parameters) { (result: Result<[VideoDataModel], Error>) in
            switch result {
            case let .failure(error):
                print("Network request error: \(error)")
            case let .success(videoDataModel):
                block(videoDataModel)
            }
        }
    }

    public func pullProfileData(email: String, block: @escaping ([VideoDataModel]) -> Void) {
        let userParameters: Parameters = ["email": email]

        NetworkManager.call(endpoint: "/api/user", method: .get, parameters: userParameters) { (result: Result<UserModel, Error>) in
            switch result {
            case let .failure(error):
                print("Network request error: \(error)")
            case let .success(userModel):
                let profileParameters: Parameters = ["email": email,
                                                     "user": userModel.id ?? 0]

                NetworkManager.call(endpoint: "/api/profile", method: .get, parameters: profileParameters) { (result: Result<[VideoDataModel], Error>) in
                    switch result {
                    case let .failure(error):
                        print("Network request error: \(error)")
                    case let .success(videoDataModels):
                        block(videoDataModels)
                    }
                }
            }
        }
    }

    public func sendPoints(email: String, videoId: Int, point: Int, block: @escaping (SignUpModel) -> Void) {
        let parameters: Parameters = ["email": email,
                                      "video": videoId,
                                      "point": point]

        NetworkManager.call(endpoint: "/api/like-vid", method: .post, parameters: parameters) { (result: Result<SignUpModel, Error>) in
            switch result {
            case let .failure(error):
                print("Network request error: \(error)")
            case let .success(signUpModel):
                block(signUpModel)
            }
        }
    }

    public func spamPost(type: Int, id: Int, block: @escaping (SignUpModel) -> Void) {
        let parameters: Parameters = ["email": CacheUser.email,
                                      "video": id,
                                      "type": type]

        NetworkManager.call(endpoint: "/api/spam", method: .post, parameters: parameters) { (result: Result<SignUpModel, Error>) in
            switch result {
            case let .failure(error):
                print("Network request error: \(error)")
            case let .success(signUpModel):
                block(signUpModel)
            }
        }
    }
}
