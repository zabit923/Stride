//
//  AddInfoAboutCourseVC.swift
//  Courses
//
//  Created by Ибрагимов Эльдар on 18.07.2024.
//

import UIKit

class AddInfoAboutCourseVC: UIViewController {

    @IBOutlet weak var categoryBorder: Border!
    @IBOutlet weak var priceBorder: Border!
    @IBOutlet weak var descriptionBorder: Border!
    @IBOutlet weak var nameBorder: Border!
    @IBOutlet weak var imageBtn: UIButton!
    @IBOutlet weak var pricePred: UILabel!
    @IBOutlet weak var coachPred: UILabel!
    @IBOutlet weak var namePred: UILabel!
    @IBOutlet weak var imagePred: UIImageView!
    @IBOutlet weak var price: UITextField!
    @IBOutlet weak var descriptionCourse: UITextField!
    @IBOutlet weak var name: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        price.delegate = self
        descriptionCourse.delegate = self
        name.delegate = self
        
    }
    
    @IBAction func save(_ sender: UIButton) {
        performSegue(withIdentifier: "goToAddModule", sender: self)
    }
    
    @IBAction func addImage(_ sender: UIButton) {
        
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func tap(_ sender: UITapGestureRecognizer) {
        price.resignFirstResponder()
        descriptionCourse.resignFirstResponder()
        name.resignFirstResponder()
        
    }
}

extension AddInfoAboutCourseVC: UITextFieldDelegate {
    
}
