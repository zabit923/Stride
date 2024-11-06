//
//  UpdateViewController.swift
//  Courses
//
//  Created by Руслан on 09.10.2024.
//

import UIKit

class UpdateViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

   
    @IBAction func update(_ sender: UIButton) {
        UIApplication.shared.open(URL(string: "https://apps.apple.com/ru/app/stride/id6737005692")!)
    }
    

}
