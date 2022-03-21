//
//  NetworkManager.swift
//  SenSoyleAvrupa
//
//  Created by Ebu Celik on 17.02.22.
//

import Alamofire
import Combine
import ComposableArchitecture

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
        AF.request(domain + endpoint, method: method, parameters: parameters).responseJSON { response in
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

    static func call<T: Codable>(domain: String = url,
                                 endpoint: String,
                                 method: HTTPMethod,
                                 parameters: Parameters) -> AnyPublisher<T, APIError> {
        // Deferred defer (verschieben) the Future to execute it when it will be subscribed.
        return Deferred {

            // Future executes his closure immediately when it will be initialized.
            // Therefore we use Deferred to execute it when subscribed.
            Future { promise in
                AF.request(domain + endpoint, method: method, parameters: parameters).responseJSON { response in
                    print(response)

                    if let data = response.data {
                        do {
                            let model = try JSONDecoder().decode(T.self, from: data)

                            promise(.success(model))
                        } catch {
                            promise(.failure(APIError(error: error)))
                        }
                    } else {
                        promise(.failure(APIError(error: NetworkError.dataCorrupted(response.error?.localizedDescription ?? ""))))
                    }
                }
            }
        }.eraseToAnyPublisher()
    }

    static func upload(domain: String = url,
                       endpoint: String,
                       parameters: [String: String],
                       data: Data?,
                       url: URL?,
                       mimeType: String) -> AnyPublisher<Int, APIError> {
        return Deferred {
            Future { promise in
                AF.upload(multipartFormData: { multipartFormData in
                    for (key, value) in parameters {
                        multipartFormData.append(value.data(using: .utf8)!, withName: key)
                    }

                    if let data = data {
                        multipartFormData.append(data, withName: "file", fileName: "file", mimeType: mimeType)
                    } else if let url = url {
                        multipartFormData.append(url, withName: "file", fileName: "file", mimeType: mimeType)
                    }
                }, to: domain + endpoint)
                    .response { response in
                        if let httpResponse = response.response, httpResponse.statusCode == 200 {
                            promise(.success(httpResponse.statusCode))
                        } else {
                            if let error = response.error {
                                promise(.failure(APIError(error: error)))
                            } else {
                                promise(.failure(APIError(error: NSError(domain: domain + endpoint, code: 500, userInfo: nil))))
                            }
                        }
                    }
            }
        }.eraseToAnyPublisher()
    }
}
