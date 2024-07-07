//
//  ChangeInformationViewController.swift
//  Courses
//
//  Created by Ибрагимов Эльдар on 05.07.2024.
//

import UIKit

class ChangeInformationViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func back(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}
