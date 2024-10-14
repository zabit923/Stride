//
//  NavigationControllerDelegate.swift
//  Courses
//
//  Created by Руслан on 09.10.2024.
//

import UIKit

extension StartViewController: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if viewController is InfoCoursesViewController {
            navigationController.interactivePopGestureRecognizer?.isEnabled = true
        } else {
            navigationController.interactivePopGestureRecognizer?.isEnabled = false
        }
    }
    
}
