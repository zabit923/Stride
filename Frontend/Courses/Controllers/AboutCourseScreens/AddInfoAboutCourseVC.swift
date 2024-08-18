//
//  AddInfoAboutCourseVC.swift
//  Courses
//
//  Created by Ибрагимов Эльдар on 18.07.2024.
//

import UIKit

class AddInfoAboutCourseVC: UIViewController {

    @IBOutlet weak var imageBorder: Border!
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
    @IBOutlet weak var descriptionCourse: UITextView!
    @IBOutlet weak var name: UITextField!
    
    private var infoCourses = Course()
    var idCourse = 0
    private var imageURL: URL?
    var create = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        price.delegate = self
        name.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getCourse()
        addCoach()
    }
    
    private func getCourse() {
        guard create == false else { return }
        Task {
            infoCourses = try await Courses().getCoursesByID(id: idCourse)
            design()
        }
    }
    
    private func design() {
        imagePred.sd_setImage(with: infoCourses.imageURL)
        namePred.text = infoCourses.nameCourse
        pricePred.text = "\(infoCourses.price)Р"
        name.text = infoCourses.nameCourse
        price.text = "\(infoCourses.price)"
        descriptionCourse.text = infoCourses.description
        imageURL = infoCourses.imageURL
    }
    
    func checkError() -> Bool {
        var result = true
        if name.text!.isEmpty {
            nameBorder.layer.borderColor = UIColor.errorRed.cgColor
            result = false
        }else {
            nameBorder.layer.borderColor = UIColor.lightBlackMain.cgColor
        }
        if price.text!.isEmpty {
            result = false
            priceBorder.layer.borderColor = UIColor.errorRed.cgColor
        }else {
            priceBorder.layer.borderColor = UIColor.lightBlackMain.cgColor
        }
        if descriptionCourse.text!.isEmpty {
            result = false
            descriptionBorder.layer.borderColor = UIColor.errorRed.cgColor
        }else {
            descriptionBorder.layer.borderColor = UIColor.lightBlackMain.cgColor
        }
        if imagePred.image == nil || imageURL == nil{
            result = false
            imageBorder.layer.borderColor = UIColor.errorRed.cgColor
        }else {
            imageBorder.layer.borderColor = UIColor.lightBlackMain.cgColor
        }
        return result
    }
    
    func addCoach() {
        let coach = User.info
        coachPred.text = "\(coach.name) \(coach.surname)"
    }
    
    func addInfoInVar() {
        infoCourses.nameCourse = name.text!
        infoCourses.price = Int(price.text!) ?? 0
        infoCourses.description = descriptionCourse.text!
        infoCourses.imageURL = imageURL
    }
    
    @IBAction func save(_ sender: UIButton) {
        
        if checkError() {
            Task {
                addInfoInVar()
                if create {
                    idCourse = try await Courses().saveInfoCourse(info: infoCourses, method: .post)
                }else {
                    idCourse = try await Courses().saveInfoCourse(info: infoCourses, method: .patch)
                }
                performSegue(withIdentifier: "goToAddModule", sender: self)
            }
        }
    }
    
    
    @IBAction func addImage(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        present(imagePicker, animated: true)
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func tap(_ sender: UITapGestureRecognizer) {
        price.resignFirstResponder()
        descriptionCourse.resignFirstResponder()
        name.resignFirstResponder()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToAddModule" {
            let vc = segue.destination as! AddModuleCoursesViewController
            vc.idCourse = idCourse
        }
        
    }
    
}
extension AddInfoAboutCourseVC: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage, let url = info[.imageURL] as? URL {
            imagePred.image = image
            imageURL = url
            dismiss(animated: true)
        }
    }
    
}
extension AddInfoAboutCourseVC: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField == name {
            namePred.text = textField.text
        }else if textField == price {
            pricePred.text = "\(textField.text!)Р"
        }
    }
}

