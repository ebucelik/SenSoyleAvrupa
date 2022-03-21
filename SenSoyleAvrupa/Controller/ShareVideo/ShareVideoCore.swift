//
//  ShareVideoCore.swift
//  SenSoyleAvrupa
//
//  Created by Ing. Ebu Celik on 21.03.22.
//

import Combine
import ComposableArchitecture

typealias ShareVideoLoadingState = Loadable<Int>
typealias CoinSettingsLoadingState = Loadable<CoinSettingsModel>
typealias UserLoadingState = Loadable<UserModel>

struct ShareVideoState: Equatable {
    var shareVideoLoadingState: ShareVideoLoadingState = .none
    var shareVideoStatusCode: Int?

    var coinSettingsLoadingState: CoinSettingsLoadingState = .none
    var coinSettingsModel: CoinSettingsModel?

    var userLoadingState: UserLoadingState = .none
    var userModel: UserModel?

    var coins: Int = 0
}

enum ShareVideoAction {
    case shareVideo(email: String, comment: String, url: URL?)
    case shareVideoUpdated(shareVideoLoadingState: ShareVideoLoadingState)

    case getCoinSettings
    case coinSettingsModelUpdated(coinSettingsLoadingState: CoinSettingsLoadingState)

    case getUser(email: String)
    case userModelUpdated(userLoadingState: UserLoadingState)
}

struct ShareVideoEnvironment {
    var service: ShareVideoServiceProtocol
    var mainQueue: AnySchedulerOf<DispatchQueue>
}

let shareVideoReducer = Reducer<ShareVideoState, ShareVideoAction, ShareVideoEnvironment> { state, action, environment in
    switch action {
    case let .shareVideo(email, comment, url):
        return environment.service
            .shareVideo(email: email, comment: comment, url: url)
            .catchToEffect()
            .map { result in
                switch result {
                case let .failure(error):
                    return .shareVideoUpdated(shareVideoLoadingState: .error(error))

                case let .success(statusCode):
                    return .shareVideoUpdated(shareVideoLoadingState: .loaded(statusCode))
                }
            }
            .prepend(.shareVideoUpdated(shareVideoLoadingState: .loading))
            .eraseToEffect()

    case let .shareVideoUpdated(shareVideoLoadingState):
        state.shareVideoLoadingState = shareVideoLoadingState

        if case let .loaded(statusCode) = shareVideoLoadingState {
            state.shareVideoStatusCode = statusCode
        }

        return .none

    case .getCoinSettings:
        return environment.service
            .getCoinSettings()
            .catchToEffect()
            .map { result in
                switch result {
                case let .failure(error):
                    return .coinSettingsModelUpdated(coinSettingsLoadingState: .error(error))

                case let .success(coinSettingsModel):
                    return .coinSettingsModelUpdated(coinSettingsLoadingState: .loaded(coinSettingsModel))
                }
            }
            .prepend(.coinSettingsModelUpdated(coinSettingsLoadingState: .loading))
            .eraseToEffect()

    case let .coinSettingsModelUpdated(coinSettingsLoadingState):
        state.coinSettingsLoadingState = coinSettingsLoadingState

        if case let .loaded(coinSettingsModel) = coinSettingsLoadingState {
            state.coins = coinSettingsModel.first_coin ?? 0
            state.coinSettingsModel = coinSettingsModel
        }

        return .none

    case let .getUser(email):
        return environment.service
            .getUser(email: email)
            .catchToEffect()
            .map { result in
                switch result {
                case let .failure(error):
                    return .userModelUpdated(userLoadingState: .error(error))

                case let .success(userModel):
                    return .userModelUpdated(userLoadingState: .loaded(userModel))
                }
            }
            .prepend(.userModelUpdated(userLoadingState: .loading))
            .eraseToEffect()

    case let .userModelUpdated(userLoadingState):
        state.userLoadingState = userLoadingState

        if case let .loaded(userModel) = userLoadingState {
            state.userModel = userModel
        }

        return .none
    }
}
