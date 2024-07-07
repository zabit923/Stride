//
//  InfoAboutMeViewController.swift
//  Courses
//
//  Created by Ибрагимов Эльдар on 06.07.2024.
//

import UIKit

class InfoAboutMeViewController: UIViewController {
    @IBOutlet weak var viewHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        design()
        
    }

    func design() {
        viewHeight.constant = UIScreen.main.bounds.height / 2 + UIScreen.main.bounds.height / 10
    }
    
    
    
}
