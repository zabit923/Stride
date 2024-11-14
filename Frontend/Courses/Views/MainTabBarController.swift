//
//  ViewController.swift
//  Courses
//
//  Created by Руслан on 07.11.2024.
//

import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setTabBarApearence()
        setViewControllersInTaBar()
    }
    
    private func setViewControllersInTaBar() {
        guard let vc = viewControllers else { return }
        for x in 0...vc.count - 1 {
            if let image = vc[x].tabBarItem.selectedImage {
                vc[x].tabBarItem.selectedImage = image.withRenderingMode(.alwaysOriginal)
            }
            if let image = vc[x].tabBarItem.image {
                vc[x].tabBarItem.image = image.withRenderingMode(.alwaysOriginal)
            }
        }
    }
    
    private func generateVC(vc: UIViewController ,image:UIImage, selectedImage: UIImage) -> UIViewController {
        let viewController = vc
        viewController.tabBarItem.image = image.withRenderingMode(.alwaysOriginal)
        viewController.tabBarItem.selectedImage = selectedImage.withRenderingMode(.alwaysOriginal)
        return viewController
    }

    private func setTabBarApearence() {
        let width = tabBar.bounds.width - 70
        let height: CGFloat = 60
        
        let roundLayer = CAShapeLayer()
        let bezierPath = UIBezierPath(roundedRect: CGRect(x: tabBar.bounds.minX + 35, y: tabBar.bounds.minY - 5, width: width, height: height), cornerRadius: 20)
        
//        roundLayer.strokeColor = UIColor.blackMain.cgColor
//        roundLayer.lineWidth = 1
        roundLayer.fillColor = UIColor.lightBlackMain.cgColor
        roundLayer.path = bezierPath.cgPath
        
        tabBar.layer.insertSublayer(roundLayer, at: 0)
        tabBar.itemWidth = 45
        tabBar.backgroundColor = .clear
        tabBar.backgroundImage = UIImage()
        tabBar.shadowImage = UIImage()

        tabBar.itemPositioning = .centered
        
        tabBar.layer.shadowOpacity = 0.42
        tabBar.layer.shadowOffset = CGSize(width: 0, height: -2)
        tabBar.layer.shadowRadius = 20
        tabBar.layer.shadowColor = UIColor.black.cgColor
        tabBar.layer.masksToBounds = false
    }
}
