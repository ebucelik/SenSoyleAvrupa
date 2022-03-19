//
//  ViewControllerService.swift
//  SenSoyleAvrupa
//
//  Created by Ing. Ebu Celik on 04.03.22.
//

import Foundation
import Alamofire

public protocol SharedServiceProtocol {
    func pullVideoData(email: String, block: @escaping ([VideoDataModel]) -> Void)
    func pullUserData(email: String, block: @escaping (UserModel) -> Void)
    func pullProfileData(email: String, userId: Int, block: @escaping ([VideoDataModel]) -> Void)
    func sendPoints(email: String, videoId: Int, point: Int, block: @escaping (SignUpModel) -> Void)
    func spamPost(type: Int, id: Int, block: @escaping (SignUpModel) -> Void)
    func changeUsername(email: String, username: String, onError: (() -> Void)?, block: @escaping (SignUpModel) -> Void)
}

public final class SharedService: SharedServiceProtocol {

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

    public func pullUserData(email: String, block: @escaping (UserModel) -> Void) {
        let parameters: Parameters = ["email": email]

        NetworkManager.call(endpoint: "/api/user", method: .get, parameters: parameters) { (result: Result<UserModel, Error>) in
            switch result {
            case let .failure(error):
                print("Network request error: \(error)")
            case let .success(userModel):
                block(userModel)
            }
        }
    }

    public func pullProfileData(email: String, userId: Int, block: @escaping ([VideoDataModel]) -> Void) {
        let parameters: Parameters = ["email": email,
                                             "user": userId]

        NetworkManager.call(endpoint: "/api/profile", method: .get, parameters: parameters) { (result: Result<[VideoDataModel], Error>) in
            switch result {
            case let .failure(error):
                print("Network request error: \(error)")
            case let .success(videoDataModels):
                block(videoDataModels)
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

    public func changeUsername(email: String, username: String, onError: (() -> Void)? = nil, block: @escaping (SignUpModel) -> Void) {
        let parameters: Parameters = ["email": email,
                                      "newUsername": username]

        NetworkManager.call(endpoint: "/api/change-username", method: .post, parameters: parameters) { (result: Result<SignUpModel, Error>) in
            switch result {
            case let .failure(error):
                print("Network request error: \(error)")

                guard let onError = onError else {
                    return
                }

                onError()
            case let .success(signUpModel):
                block(signUpModel)
            }
        }
    }
}
