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
        
        let homeController = navControllerOlustur(rootViewController: HomeController(service: ViewControllerService()),
                                                  seciliOlmayanIcon: UIImage(systemName: "music.note.house") ?? UIImage(),
                                                  title: "Ana sayfa")
        
//        let shareVideoController = navControllerOlustur(rootViewController: ShareVideoController(), seciliOlmayanIcon: UIImage(systemName: "plus.rectangle.fill") ?? UIImage(), title: "Video paylaş")
        
//        let purchaseCoinController = navControllerOlustur(rootViewController: PurchaseCoinController(), seciliOlmayanIcon: UIImage(systemName: "dollarsign.circle") ?? UIImage(), title: "Satın Al")
        
        let profileController = navControllerOlustur(rootViewController: ProfileController(email: CacheUser.email,
                                                                                           isOwnUserProfile: true),
                                                     seciliOlmayanIcon: UIImage(systemName: "person.fill.viewfinder") ?? UIImage(),
                                                     title: "Profil")
        
        viewControllers = [homeController,profileController]
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = true
    }
    
    fileprivate func navControllerOlustur(rootViewController : UIViewController = UIViewController(),seciliOlmayanIcon : UIImage,title : String) -> UINavigationController {
        rootViewController.title = title
        let rootController = rootViewController
        let navController = UINavigationController(rootViewController: rootController)
        //navController.title = title
        navController.navigationBar.barTintColor = .white
        //navController.navigationBar.tintColor = .white
        navController.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.customLabelColor()]
        navController.tabBarItem.image = seciliOlmayanIcon
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

