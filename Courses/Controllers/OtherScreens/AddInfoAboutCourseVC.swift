//
//  AddInfoAboutCourseVC.swift
//  Courses
//
//  Created by Ибрагимов Эльдар on 18.07.2024.
//

import UIKit

class AddInfoAboutCourseVC: UIViewController {

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
        name.delegate = self
        price.delegate = self
        descriptionCourse.delegate = self
        addCoach()
    }
    
    func addCoach() {
        let coach = UD().getMyInfo()
        coachPred.text = "\(coach.name) \(coach.surname)"
    }
    
    @IBAction func save(_ sender: UIButton) {
        
    }
    
    @IBAction func addImage(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        present(imagePicker, animated: true)
    }
    
    @IBAction func tap(_ sender: UITapGestureRecognizer) {
        price.resignFirstResponder()
        descriptionCourse.resignFirstResponder()
        name.resignFirstResponder()
    }
    
}
extension AddInfoAboutCourseVC: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            imagePred.image = image
            dismiss(animated: true)
        }
    }
    
}
extension AddInfoAboutCourseVC: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField == name {
            namePred.text = textField.text
        }else if textField == price {
            pricePred.text = "\(textField.text!)$"
        }
    }
}
