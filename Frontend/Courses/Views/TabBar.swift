//
//  TabBar.swift
//  Courses
//
//  Created by Руслан on 11.07.2024.
//

import Foundation
import UIKit


class TabBarController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewControllers![3]
        self.viewControllers![3].tabBarItem.image = UIImage.profile
        self.setViewControllers(viewControllers, animated: true)
    }

}
