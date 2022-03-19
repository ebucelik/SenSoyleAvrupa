//
//  SceneDelegate.swift
//  SenSoyleAvrupa
//
//  Created by ilyas abiyev on 12.04.21.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        let vc = SplashViewController(service: Services.sharedService)
        let navigationVc = UINavigationController(rootViewController: vc)
        window?.rootViewController = navigationVc
        guard let _ = (scene as? UIWindowScene) else { return }
    }
}

