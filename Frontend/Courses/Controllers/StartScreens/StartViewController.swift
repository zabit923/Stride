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
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        self.navigationController?.navigationBar.isHidden = true
        current()
    }

    func current() {
        if UD().getCurrent() == true {
            performSegue(withIdentifier: "current", sender: self)
        }
    }

}
