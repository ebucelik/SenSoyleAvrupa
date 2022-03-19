//
//  LoginCore.swift
//  SenSoyleAvrupa
//
//  Created by Ing. Ebu Celik on 14.03.22.
//

import Combine
import ComposableArchitecture
import Alamofire

public typealias SignUpModelLoadingState = Loadable<SignUpModel>

struct LoginState: Equatable {
    public var loadingSignUpModel: SignUpModelLoadingState = .none
    public var signUpModel: SignUpModel?

    public var email: String = ""
}

enum LoginAction {
    case login(email: String, password: String)
    case loginStateChanged(SignUpModelLoadingState)
}

struct LoginEnvironment {
    var service: LoginServiceProtocol
    var mainQueue: AnySchedulerOf<DispatchQueue>
}

let loginReducer = Reducer<LoginState, LoginAction, LoginEnvironment> { state, action, environment in
    switch action {
    case let .login(email, password):
        state.email = email

        return environment.service.login(email: email, password: password)
            .receive(on: environment.mainQueue)
            .catchToEffect()
            .map { result in
                switch result {
                case let .failure(error):
                    return .loginStateChanged(.error(error))
                case let .success(signUpModel):
                    return .loginStateChanged(.loaded(signUpModel))
                }
            }
            .prepend(.loginStateChanged(.loading))
            .eraseToEffect()

    case let .loginStateChanged(loadingSignUpModel):
        state.loadingSignUpModel = loadingSignUpModel

        if case let .loaded(signUpModel) = loadingSignUpModel {
            state.signUpModel = signUpModel
        } else {
            state.signUpModel = nil
        }

        return .none
    }
}
