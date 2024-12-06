//
//  AppDelegate.swift
//  RickAndMortyApp
//
//  Created by Камиль Байдиев on 27.07.2024.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        let tabBarController = createTabBarController()
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
                
        return true
    }

    private func createTabBarController() -> UITabBarController {
        let tabBarController = UITabBarController()

        let episodesVC = UINavigationController(rootViewController: EpisodesViewController())
        episodesVC.tabBarItem = UITabBarItem(title: "", image: UIImage(systemName: "house"), tag: 0)

        let favouritesVC = UINavigationController(rootViewController: FavouritesViewController())
        favouritesVC.tabBarItem = UITabBarItem(title: "", image: UIImage(systemName: "star"), tag: 1)

        tabBarController.viewControllers = [episodesVC, favouritesVC]
        return tabBarController
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
}
