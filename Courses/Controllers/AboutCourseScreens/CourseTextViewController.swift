//
//  CourseTextViewController.swift
//  Courses
//
//  Created by Руслан on 14.07.2024.
//

import UIKit

class CourseTextViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var nameCourse: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func back(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    

}
