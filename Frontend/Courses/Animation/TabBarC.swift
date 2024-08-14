//
//  TabBarC.swift
//  Courses
//
//  Created by Руслан on 07.07.2024.
//

import UIKit

class TabBarC: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
        if item.title! == "Профиль" {
            self.tabBarController?.viewControllers![3] = SettingsViewController()
        }
    }

}
