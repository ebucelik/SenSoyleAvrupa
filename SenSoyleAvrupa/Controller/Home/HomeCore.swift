//
//  HomeCore.swift
//  SenSoyleAvrupa
//
//  Created by Ing. Ebu Celik on 26.03.22.
//

import Combine
import ComposableArchitecture

public struct HomeState: Equatable {
    var loadingVideoDataModels: VideoDataModelLoadingState = .none
    var videoDataModels: [VideoDataModel]?

    var loadingSignUpModel: SignUpModelLoadingState = .none
    var spamSignUpModel: SignUpModel?
    var pointsSignUpModel: SignUpModel?
}

public enum HomeAction {
    case loadingVideoDataModels(email: String)
    case videoDataModelsStateChanged(loadingVideoDataModels: VideoDataModelLoadingState)

    case sendSpam(videoId: Int, type: Int)
    case spamSignUpModelStateChanged(loadingSignUpModel: SignUpModelLoadingState)

    case sendPoints(email: String, videoId: Int, point: Int)
    case pointsSignUpModelStateChanged(loadingSignUpModel: SignUpModelLoadingState)
}

public struct HomeEnvironment {
    var service: HomeServiceProtocol
    var mainQueue: AnySchedulerOf<DispatchQueue>
}

let homeReducer = Reducer<HomeState, HomeAction, HomeEnvironment> { state, action, environment in
    switch action {
    case let .loadingVideoDataModels(email):
        return environment.service
            .loadVideoData(email: email)
            .catchToEffect()
            .map { result in
                switch result {
                case let .failure(error):
                    return .videoDataModelsStateChanged(loadingVideoDataModels: .error(error))

                case let .success(videoDataModels):
                    return .videoDataModelsStateChanged(loadingVideoDataModels: .loaded(videoDataModels))
                }
            }
            .prepend(.videoDataModelsStateChanged(loadingVideoDataModels: .loading))
            .eraseToEffect()

    case let .videoDataModelsStateChanged(loadingVideoDataModels):
        state.loadingVideoDataModels = loadingVideoDataModels

        if case let .loaded(videoDataModels) = loadingVideoDataModels {
            if state.videoDataModels != videoDataModels {
                state.videoDataModels = videoDataModels
            }
        }

        return .none

    case let .sendSpam(videoId, type):
        return environment.service
            .sendSpam(videoId: videoId, type: type)
            .catchToEffect()
            .map { result in
                switch result {
                case let .failure(error):
                    return .spamSignUpModelStateChanged(loadingSignUpModel: .error(error))

                case let .success(signUpModel):
                    return .spamSignUpModelStateChanged(loadingSignUpModel: .loaded(signUpModel))
                }
            }
            .prepend(.spamSignUpModelStateChanged(loadingSignUpModel: .loading))
            .eraseToEffect()

    case let .spamSignUpModelStateChanged(loadingSignUpModel):
        state.loadingSignUpModel = loadingSignUpModel

        if case let .loaded(signUpModel) = loadingSignUpModel {
            state.spamSignUpModel = signUpModel
        }

        return .none

    case let .sendPoints(email, videoId, point):
        return environment.service
            .sendPoints(email: email, videoId: videoId, point: point)
            .catchToEffect()
            .map { result in
                switch result {
                case let .failure(error):
                    return .pointsSignUpModelStateChanged(loadingSignUpModel: .error(error))

                case let .success(signUpModel):
                    return .pointsSignUpModelStateChanged(loadingSignUpModel: .loaded(signUpModel))
                }
            }
            .prepend(.pointsSignUpModelStateChanged(loadingSignUpModel: .loading))
            .eraseToEffect()

    case let .pointsSignUpModelStateChanged(loadingSignUpModel):
        state.loadingSignUpModel = loadingSignUpModel

        if case let .loaded(signUpModel) = loadingSignUpModel {
            state.pointsSignUpModel = signUpModel
        }

        return .none
    }
}
