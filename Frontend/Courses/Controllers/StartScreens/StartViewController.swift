//
//  StartViewController.swift
//  Courses
//
//  Created by Руслан on 22.06.2024.
//

import UIKit

class StartViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        navigationController?.delegate = self
        current()
    }

    func current() {
        if UD().getCurrent() == true {
            performSegue(withIdentifier: "current", sender: self)
        }
    }

}
