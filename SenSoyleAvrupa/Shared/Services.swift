//
//  Services.swift
//  SenSoyleAvrupa
//
//  Created by Ing. Ebu Celik on 18.03.22.
//

import Foundation

final class Services {

    // MARK: SharedService
    static var sharedService: SharedServiceProtocol {
        SharedService()
    }

    // MARK: LoginService
    static var loginService: LoginServiceProtocol {
        LoginService()
    }

    // MARK: RegistrationService
    static var registrationService: RegistrationServiceProtocol {
        RegistrationService()
    }

    // MARK: ChooseProfileImageService
    static var chooseProfileImageService: ChooseProfileImageServiceProtocol {
        ChooseProfileImageService()
    }

    // MARK: ShareVideoService
    static var shareVideoService: ShareVideoServiceProtocol {
        ShareVideoService()
    }

    // MARK: ProfileService
    static var profileService: ProfileServiceProtocol {
        ProfileService()
    }
}
