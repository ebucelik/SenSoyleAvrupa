//
//  ChooseProfileImageService.swift
//  SenSoyleAvrupa
//
//  Created by Ing. Ebu Celik on 19.03.22.
//

import Alamofire
import Combine
import AVFoundation

public protocol ChooseProfileImageServiceProtocol {
    func uploadImage(email: String, jpegData: Data) -> AnyPublisher<Int, APIError>
}

final class ChooseProfileImageService: ChooseProfileImageServiceProtocol {
    func uploadImage(email: String, jpegData: Data) -> AnyPublisher<Int, APIError> {
        let parameters = ["email": email]

        return NetworkManager.upload(endpoint: "/api/upload-pp", parameters: parameters, data: jpegData, url: nil, mimeType: ".png")
    }
}
