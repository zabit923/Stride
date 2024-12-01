//
//  ViewController.swift
//  Courses
//
//  Created by Руслан on 07.11.2024.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    private let maskView = UIView()


    override func viewDidLoad() {
        super.viewDidLoad()
        setTabBarApearence()
        setViewControllersInTaBar()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle {
            setViewControllersInTaBar()
        }
    }
    
    private func setViewControllersInTaBar() {
        guard let vc = viewControllers else { return }
        let theme = traitCollection.userInterfaceStyle
        print(vc.count)
        vc[0].tabBarItem = selectImageByTabBarItem(image: "home", theme: theme)
        vc[1].tabBarItem = selectImageByTabBarItem(image: "catalog", theme: theme)
        vc[2].tabBarItem = selectImageByTabBarItem(image: "courses", theme: theme)
        vc[3].tabBarItem = selectImageByTabBarItem(image: "profile", theme: theme)
        if vc.count == 5 {
            vc[4].tabBarItem = selectImageByTabBarItem(image: "profile", theme: theme)
        }
    }
    
    private func selectImageByTabBarItem(image: String, theme: UIUserInterfaceStyle ) -> UITabBarItem {
        let item = UITabBarItem()
        
        if theme == .dark {
            item.selectedImage = UIImage(named: image + "Select")?.withRenderingMode(.alwaysOriginal)
            item.image = UIImage(named: image)?.withRenderingMode(.alwaysOriginal)
        }else {
            item.selectedImage = UIImage(named: image + "Select" + "Light")?.withRenderingMode(.alwaysOriginal)
            item.image = UIImage(named: image + "Light")?.withRenderingMode(.alwaysOriginal)
        }
        
        return item
    }
   



    private func setTabBarApearence() {
        let width = tabBar.bounds.width - 70
        let height: CGFloat = 60
        
        
        maskView.frame = CGRect(x: tabBar.bounds.minX + 35, y: tabBar.bounds.minY - 10, width: width, height: height)
        maskView.backgroundColor = UIColor.tabBar
        maskView.layer.cornerRadius = 30
        tabBar.addSubview(maskView)
        
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
