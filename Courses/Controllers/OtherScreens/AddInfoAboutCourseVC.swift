//
//  AddInfoAboutCourseVC.swift
//  Courses
//
//  Created by Ибрагимов Эльдар on 18.07.2024.
//

import UIKit

class AddInfoAboutCourseVC: UIViewController {

    @IBOutlet weak var viewPhoto: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        design()
        
    }
    
    func design() {
        viewPhoto.layer.borderWidth = 2
        viewPhoto.layer.borderColor = UIColor(named: "ExtraLightBlackMain")?.cgColor
    }

}
