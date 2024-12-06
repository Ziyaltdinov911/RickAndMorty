//
//  LaunchScreenViewController.swift
//  RickAndMortyApp
//
//  Created by Камиль Байдиев on 27.07.2024.
//

import UIKit

class LaunchScreenViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        let titleImageView = UIImageView(image: UIImage(named: "RickAndMorty"))
        view.addSubview(titleImageView)
        titleImageView.frame = CGRect(x: (view.frame.width - 300) / 2,
                                      y: (view.frame.height - 400) / 2 - 100,
                                      width: 300,
                                      height: 100)
    
        let portalImageView = UIImageView(image: UIImage(named: "portal"))
        view.addSubview(portalImageView)
        portalImageView.frame = CGRect(x: (view.frame.width - 200) / 2,
                                       y: (view.frame.height - 200) / 2,
                                       width: 200,
                                       height: 200)

        let rotation = CABasicAnimation(keyPath: "transform.rotation")
        rotation.fromValue = 0
        rotation.toValue = Double.pi * 2
        rotation.duration = 1
        rotation.repeatCount = Float.infinity
        portalImageView.layer.add(rotation, forKey: "rotation")

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            let tabBarController = UITabBarController()
            UITabBar.appearance().itemPositioning = .centered
            UITabBar.appearance().itemSpacing = 40

            let episodesVC = EpisodesViewController()
            let episodesNavController = UINavigationController(rootViewController: episodesVC)
            let homeImage = UIImage(named: "home")?.resized(to: CGSize(width: 30, height: 30))
            let homeSelectedImage = UIImage(named: "home")?.resized(to: CGSize(width: 30, height: 30))
            episodesNavController.tabBarItem = UITabBarItem(title: "", image: homeImage, selectedImage: homeSelectedImage)
            
            let favouritesVC = FavouritesViewController()
            let favouritesNavController = UINavigationController(rootViewController: favouritesVC)
            let heartImage = UIImage(systemName: "heart")?.resized(to: CGSize(width: 40, height: 35))
            let heartSelectedImage = UIImage(systemName: "heart.fill")?.resized(to: CGSize(width: 40, height: 35))
            favouritesNavController.tabBarItem = UITabBarItem(title: "", image: heartImage, selectedImage: heartSelectedImage)
            tabBarController.tabBar.backgroundColor = .white
            tabBarController.tabBar.layer.borderWidth = 0.1
            tabBarController.viewControllers = [episodesNavController, favouritesNavController]

            UIApplication.shared.windows.first?.rootViewController = tabBarController
        }
    }
}

extension UIImage {
    func resized(to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        draw(in: CGRect(origin: .zero, size: size))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage
    }
}
