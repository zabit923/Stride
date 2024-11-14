//
//  MainTabBarItem.swift
//  Courses
//
//  Created by Руслан on 09.11.2024.
//

import UIKit

class MainTabBarItem: UITabBarItem {

    override class func awakeFromNib() {
        self.image = self.image?.withRenderingMode(.alwaysOriginal)
    }
    
}
