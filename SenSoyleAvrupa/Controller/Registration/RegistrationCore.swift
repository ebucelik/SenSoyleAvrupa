//
//  RegistrationCore.swift
//  SenSoyleAvrupa
//
//  Created by Ing. Ebu Celik on 19.03.22.
//

import Combine
import ComposableArchitecture

struct RegistrationState: Equatable {
    public var loadingSignUpModel: SignUpModelLoadingState = .none
    public var signUpModel: SignUpModel?

    public var email: String = ""
}

enum RegistrationAction {
    case register(username: String, email: String, password: String)
    case registerStateChanged(SignUpModelLoadingState)
}

struct RegistrationEnvironment {
    var service: RegistrationServiceProtocol
    var mainQueue: AnySchedulerOf<DispatchQueue>
}

let registrationReducer = Reducer<RegistrationState, RegistrationAction, RegistrationEnvironment> { state, action, environment in
    switch action {
    case let .register(username, email, password):
        state.email = email

        return environment.service
            .register(username: username, email: email, password: password)
            .receive(on: environment.mainQueue)
            .catchToEffect()
            .map { result in
                switch result {
                case let .failure(error):
                    return .registerStateChanged(.error(error))
                case let .success(signUpModel):
                    return .registerStateChanged(.loaded(signUpModel))
                }
            }
            .prepend(.registerStateChanged(.loading))
            .eraseToEffect()

    case let .registerStateChanged(signUpModelLoadingState):
        state.loadingSignUpModel = signUpModelLoadingState

        if case let .loaded(signUpModel) = signUpModelLoadingState {
            state.signUpModel = signUpModel
        } else {
            state.signUpModel = nil
        }

        return .none
    }
}
