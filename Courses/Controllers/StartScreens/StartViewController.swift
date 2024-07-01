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
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        self.navigationController?.navigationBar.isHidden = true
        
    }
    

}
