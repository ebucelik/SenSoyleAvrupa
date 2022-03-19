//
//  ChooseProfileImageCore.swift
//  SenSoyleAvrupa
//
//  Created by Ing. Ebu Celik on 19.03.22.
//

import Combine
import ComposableArchitecture

public typealias StatusCodeState = Loadable<Int>

struct ChooseProfileImageState: Equatable {
    var loadingStatusCode: StatusCodeState = .none
    var statusCode: Int?
}

enum ChooseProfileImageAction {
    case uploadImage(email: String, jpegData: Data)
    case uploadImageStateChanged(loadingStatusCode: StatusCodeState)
}

struct ChooseProfileImageEnvironment {
    var service: ChooseProfileImageServiceProtocol
    var mainQueue: AnySchedulerOf<DispatchQueue>
}

let chooseProfileImageReducer = Reducer<ChooseProfileImageState, ChooseProfileImageAction, ChooseProfileImageEnvironment> { state, action, environment in
    switch action {
    case let .uploadImage(email, jpegData):
        return environment.service
            .uploadImage(email: email, jpegData: jpegData)
            .receive(on: environment.mainQueue)
            .catchToEffect()
            .map { result in
                switch result {
                case let .failure(error):
                    return .uploadImageStateChanged(loadingStatusCode: .error(error))

                case let .success(statusCode):
                    return .uploadImageStateChanged(loadingStatusCode: .loaded(statusCode))
                }
            }
            .prepend(.uploadImageStateChanged(loadingStatusCode: .loading))
            .eraseToEffect()

    case let .uploadImageStateChanged(loadingStatusCode):
        state.loadingStatusCode = loadingStatusCode

        if case let .loaded(statusCode) = loadingStatusCode {
            state.statusCode = statusCode
        } else {
            state.statusCode = nil
        }

        return .none
    }
}
