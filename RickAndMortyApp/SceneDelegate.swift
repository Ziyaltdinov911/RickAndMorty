//
//  SceneDelegate.swift
//  RickAndMortyApp
//
//  Created by Камиль Байдиев on 27.07.2024.
//

import UIKit
import Photos
import AVFoundation

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = createTabBarController()
        window.rootViewController = UINavigationController(rootViewController: LaunchScreenViewController())
        window.makeKeyAndVisible()
        
        self.window = window
        
    }
    
    private func createTabBarController() -> UITabBarController {
        let tabBarController = UITabBarController()
        
        let episodesVC = UINavigationController(rootViewController: EpisodesViewController())
        episodesVC.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "home"), tag: 0)
        
        let favouritesVC = UINavigationController(rootViewController: FavouritesViewController())
        favouritesVC.tabBarItem = UITabBarItem(title: "", image: UIImage(systemName: "star"), tag: 1)
        
        tabBarController.viewControllers = [episodesVC, favouritesVC]
        return tabBarController
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        
    }
    
}
