//
//  ProfileCore.swift
//  SenSoyleAvrupa
//
//  Created by Ing. Ebu Celik on 25.03.22.
//

import Combine
import ComposableArchitecture

public typealias UserModelLoadingState = Loadable<UserModel>
public typealias VideoDataModelLoadingState = Loadable<[VideoDataModel]>

public struct ProfileState: Equatable {
    var loadingUserModel: UserModelLoadingState = .none
    var userModel: UserModel?

    var loadingVideoDataModel: VideoDataModelLoadingState = .none
    var videoDataModels: [VideoDataModel]?

    var email: String = ""
}

public enum ProfileAction {
    case loadUser(email: String)
    case loadUserStateChanged(loadingUserModel: UserModelLoadingState)

    case loadVideos(email: String, userId: Int)
    case loadVideosStateChanged(loadingVideoDataModel: VideoDataModelLoadingState)
}

public struct ProfileEnvironment {
    var service: ProfileServiceProtocol
    var mainQeue: AnySchedulerOf<DispatchQueue>
}

let profileReducer = Reducer<ProfileState, ProfileAction, ProfileEnvironment> { state, action, environment in
    switch action {
    case let .loadUser(email):
        state.email = email

        return environment.service
            .pullUserData(email: email)
            .catchToEffect()
            .map { result in
                switch result {
                case let .failure(error):
                    return .loadUserStateChanged(loadingUserModel: .error(error))

                case let .success(userModel):
                    return .loadUserStateChanged(loadingUserModel: .loaded(userModel))
                }
            }
            .prepend(.loadUserStateChanged(loadingUserModel: .loading))
            .eraseToEffect()

    case let .loadUserStateChanged(loadingUserModel):
        state.loadingUserModel = loadingUserModel

        if case let .loaded(userModel) = loadingUserModel {
            if state.userModel != userModel {
                state.userModel = userModel
            }

            return Effect(value: .loadVideos(email: state.email, userId: userModel.id ?? 0))
        }

        return .none

    case let .loadVideos(email, userId):
        return environment.service
            .pullVideoData(email: email, userId: userId)
            .catchToEffect()
            .map { result in
                switch result {
                case let .failure(error):
                    return .loadVideosStateChanged(loadingVideoDataModel: .error(error))

                case let .success(videoDataModels):
                    return .loadVideosStateChanged(loadingVideoDataModel: .loaded(videoDataModels))
                }
            }
            .prepend(.loadVideosStateChanged(loadingVideoDataModel: .loading))
            .eraseToEffect()

    case let .loadVideosStateChanged(loadingVideoDataModel):
        state.loadingVideoDataModel = loadingVideoDataModel

        if case let .loaded(videoDataModels) = loadingVideoDataModel {
            if state.videoDataModels != videoDataModels {
                state.videoDataModels = videoDataModels
            }
        }

        return .none
    }
}
