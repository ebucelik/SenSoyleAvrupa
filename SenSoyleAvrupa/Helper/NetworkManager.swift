//
//  NetworkManager.swift
//  SenSoyleAvrupa
//
//  Created by Ebu Celik on 17.02.22.
//

import Foundation
import Alamofire

enum NetworkError: Error {
    case dataCorrupted(String)
}

class NetworkManager {
    // xlm.sensoyleavrupa.com
    static let url: String = "https://deneme.mukomedia.at"

    static func call<T: Codable>(domain: String = url,
                                 endpoint: String,
                                 method: HTTPMethod,
                                 parameters: Parameters,
                                 result: @escaping (Result<T, Error>) -> Void) {
        AF.request(url + endpoint, method: method, parameters: parameters).responseJSON { response in
            print(response)

            if let data = response.data {
                do {
                    let model = try JSONDecoder().decode(T.self, from: data)

                    result(.success(model))
                } catch {
                    result(.failure(error))
                }
            } else {
                result(.failure(NetworkError.dataCorrupted(response.error?.localizedDescription ?? "")))
            }
        }
    }
}
