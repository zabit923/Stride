//
//  AddInfoAboutCourseVC.swift
//  Courses
//
//  Created by Ибрагимов Эльдар on 18.07.2024.
//

import UIKit

class AddInfoAboutCourseVC: UIViewController {

    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var categoriesLbl: UILabel!
    @IBOutlet weak var imageBorder: Border!
    @IBOutlet weak var categoryBorder: Border!
    @IBOutlet weak var titleLbl: UILabel!
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

    private let errorView = ErrorView(frame: CGRect(x: 25, y: 54, width: UIScreen.main.bounds.width - 50, height: 70))
    private var startPosition = CGPoint()
    private var infoCourses = Course()
    private var imageURL: URL?
    private var selectCategory: Category?
    var idCourse = 0
    var create = true


    override func viewDidLoad() {
        super.viewDidLoad()
        price.delegate = self
        name.delegate = self
        startPosition = errorView.center
        view.addSubview(errorView)
        errorView.isHidden = true
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
            let categories = try await Categories().getCategories()
            selectCategory = categories.first(where: { $0.id == infoCourses.categoryID })
            categoriesLbl.text = selectCategory?.nameCategory
            design()
        }
    }

    private func design() {
        if create {
            titleLbl.text = "Создать курс"
        }else {
            titleLbl.text = "Изменить курс"
        }
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
            if Int(price.text!)! > 200000 {
                errorView.configure(title: "Ошибка", description: "Цена курса должна быть от 0 до 200.000 рублей")
                result = false
                errorView.isHidden = false
            }
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
        if categoriesLbl.text!.isEmpty {
            result = false
            categoryBorder.layer.borderColor = UIColor.errorRed.cgColor
        }else {
            categoryBorder.layer.borderColor = UIColor.lightBlackMain.cgColor
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
        infoCourses.categoryID = selectCategory!.id
    }

    @IBAction func save(_ sender: UIButton) {
        saveBtn.isEnabled = false
        errorView.isHidden = true
        guard checkError() else {return}
        Task {
            do {
                addInfoInVar()
                if create {
                    idCourse = try await Courses().saveInfoCourse(info: infoCourses, method: .post)
                }else {
                    idCourse = try await Courses().saveInfoCourse(info: infoCourses, method: .patch)
                }
                saveBtn.isEnabled = true
                performSegue(withIdentifier: "goToAddModule", sender: self)
            }catch ErrorNetwork.runtimeError(let error) {
                errorView.isHidden = false
                errorView.configure(title: "Ошибка", description: error)
                saveBtn.isEnabled = true
            }
        }
    }


    @IBAction func addImage(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        present(imagePicker, animated: true)
    }


    @IBAction func categories(_ sender: UIButton) {
        performSegue(withIdentifier: "category", sender: self)
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
        }else if segue.identifier == "category" {
            let vc = segue.destination as! PickerModelViewController
            vc.delegate = self
        }

    }


    @IBAction func swipe(_ sender: UIPanGestureRecognizer) {
        errorView.swipe(sender: sender, startPosition: startPosition)
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
extension AddInfoAboutCourseVC: AddCategoryDelegate {

    func category(category: Category) {
        categoriesLbl.text = category.nameCategory
        selectCategory = category
    }

}
