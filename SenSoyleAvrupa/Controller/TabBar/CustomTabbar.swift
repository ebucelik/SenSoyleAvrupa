//
//  TabBar.swift
//  SenSoyleAvrupa
//
//  Created by ilyas abiyev on 16.04.21.
//
import UIKit

class CustomTabbar: UITabBarController{
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tabBar.barTintColor = .customTintColor()
        
        tabBar.tintColor = .white
        
        editTabBar()
        
        delegate = self
        
        tabBar.isTranslucent = false
    }
    
    func editTabBar() {
        
        let homeController = createTabBar(
            rootViewController: HomeController(store: .init(initialState: HomeState(),
                                                            reducer: homeReducer,
                                                            environment: HomeEnvironment(service: Services.homeService,
                                                                                         mainQueue: .main))),
            unselectedIcon: UIImage(systemName: "music.note.house") ?? UIImage(),
            title: "Ana sayfa")
        
        let profileController = createTabBar(
            rootViewController: ProfileController(store: .init(initialState: ProfileState(),
                                                               reducer: profileReducer,
                                                               environment: ProfileEnvironment(service: Services.profileService,
                                                                                               mainQeue: .main)),
                                                  email: CacheUser.email,
                                                  isOwnUserProfile: true),
            unselectedIcon: UIImage(systemName: "person.fill.viewfinder") ?? UIImage(),
            title: "Profil")
        
        viewControllers = [homeController, profileController]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = true
    }
    
    fileprivate func createTabBar(rootViewController: UIViewController = UIViewController(), unselectedIcon: UIImage, title: String) -> UINavigationController {
        rootViewController.title = title

        let navController = UINavigationController(rootViewController: rootViewController)
        navController.navigationBar.barTintColor = .white
        navController.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.customLabelColor()]
        navController.tabBarItem.image = unselectedIcon
        return navController
    }
    
}

extension CustomTabbar: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return MyTransition(viewControllers: tabBarController.viewControllers)
    }
}

class MyTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    let viewControllers: [UIViewController]?
    let transitionDuration: Double = 0.2
    
    init(viewControllers: [UIViewController]?) {
        self.viewControllers = viewControllers
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return TimeInterval(transitionDuration)
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard
            let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
            let fromView = fromVC.view,
            let fromIndex = getIndex(forViewController: fromVC),
            let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to),
            let toView = toVC.view,
            let toIndex = getIndex(forViewController: toVC)
        else {
            transitionContext.completeTransition(false)
            return
        }
        
        let frame = transitionContext.initialFrame(for: fromVC)
        var fromFrameEnd = frame
        var toFrameStart = frame
        fromFrameEnd.origin.x = toIndex > fromIndex ? frame.origin.x - frame.width : frame.origin.x + frame.width
        toFrameStart.origin.x = toIndex > fromIndex ? frame.origin.x + frame.width : frame.origin.x - frame.width
        toView.frame = toFrameStart
        
        DispatchQueue.main.async {
            transitionContext.containerView.addSubview(toView)
            UIView.animate(withDuration: self.transitionDuration, animations: {
                fromView.frame = fromFrameEnd
                toView.frame = frame
            }, completion: {success in
                fromView.removeFromSuperview()
                transitionContext.completeTransition(success)
            })
        }
    }
    
    func getIndex(forViewController vc: UIViewController) -> Int? {
        guard let vcs = self.viewControllers else { return nil }
        for (index, thisVC) in vcs.enumerated() {
            if thisVC == vc { return index }
        }
        return nil
    }
}

