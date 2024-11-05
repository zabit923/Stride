//
//  AminMainViewController.swift
//  Courses
//
//  Created by Руслан on 28.10.2024.
//

import UIKit

class AdminMainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func send(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            performSegue(withIdentifier: "courses", sender: self)
        case 1:
            performSegue(withIdentifier: "money", sender: self)
        case 2:
            performSegue(withIdentifier: "allCourses", sender: self)
        default:
            break
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "allCourses" {
            let vc = segue.destination as! AdminCoursesViewController
            vc.isVerificationCourses = false
        }else if segue.identifier == "courses" {
            let vc = segue.destination as! AdminCoursesViewController
            vc.isVerificationCourses = true
        }
        
    }
    
    
    @IBAction func back(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
}
