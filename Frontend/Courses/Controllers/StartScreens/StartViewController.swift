//
//  StartViewController.swift
//  Courses
//
//  Created by Руслан on 22.06.2024.
//

import UIKit

class StartViewController: UIViewController, UIGestureRecognizerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.overrideUserInterfaceStyle = .dark
        self.navigationController?.navigationBar.isHidden = true
        current()
    }

    func current() {
        if UD().getCurrent() == true {
            performSegue(withIdentifier: "current", sender: self)
        }
    }

}
