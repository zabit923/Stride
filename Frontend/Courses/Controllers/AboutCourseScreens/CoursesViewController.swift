//
//  CoursesViewController.swift
//  Courses
//
//  Created by Руслан on 02.07.2024.
//

import UIKit
import SDWebImage
import Lottie

class CoursesViewController: UIViewController {

    @IBOutlet weak var emptyBox: LottieAnimationView!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var catalogCollectionView: UICollectionView!
    @IBOutlet weak var textField: UITextField!

    private var selectIDCourse = 0
    private var selectCourse = Course()
    var course = [Course]()
    var filteredCourse = [Course]()
    var typeCourse = CourseCatalog.recomend

    override func viewDidLoad() {
        super.viewDidLoad()
        catalogCollectionView.delegate = self
        catalogCollectionView.dataSource = self
        textField.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        design()
    }

    func design() {
        let font = UIFont(name: "Commissioner-SemiBold", size: 12)
        textField.attributedPlaceholder = NSAttributedString(string: "Поиск...", attributes: [NSAttributedString.Key.foregroundColor: UIColor.forTextFields, NSAttributedString.Key.font: font!])
        getCoursesBecauseTitle()
        loadingSettings()
    }

    private func loadingSettings() {
        emptyBox.contentMode = .scaleToFill
        emptyBox.play()
    }

    private func emptyCheck() {
        if filteredCourse.isEmpty == false {
            emptyView.isHidden = true
        }else {
            emptyView.isHidden = false
        }
    }

    private func getMyCreateCourses() {
        Task {
            course = try await Courses().getMyCreateCourses()
            filteredCourse = course
            emptyCheck()
            catalogCollectionView.reloadData()
        }
    }

    private func getRecomendCourses() {
        Task {
            course = try await Courses().getRecomendedCourses()
            filteredCourse = course
            emptyCheck()
            catalogCollectionView.reloadData()
        }
    }

    private func getCelebrityCourses() {
        Task {
            course = try await Courses().getCoursesByCelebrity()
            filteredCourse = course
            emptyCheck()
            catalogCollectionView.reloadData()
        }
    }

    private func getCoursesBecauseTitle() {
        switch typeCourse {
        case .myCreate:
            titleLbl.text = "Созданные курсы"
            getMyCreateCourses()
        case .recomend:
            titleLbl.text = "Популярные курсы"
            getRecomendCourses()
        case .popular:
            break
        case .celebrity:
            titleLbl.text = "Курсы от знаменитостей"
            getCelebrityCourses()
        }
    }

    @IBAction func back(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

}
extension CoursesViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredCourse.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "course", for: indexPath) as! CoursesCollectionViewCell
        cell.image.sd_setImage(with: filteredCourse[indexPath.row].imageURL)
        cell.nameAuthor.text = filteredCourse[indexPath.row].nameAuthor
        cell.nameCourse.text = filteredCourse[indexPath.row].nameCourse
        cell.price.text = "\(filteredCourse[indexPath.row].price)Р"
        cell.rating.text = "\(filteredCourse[indexPath.row].rating)"
        cell.daysCount.text = "\(filteredCourse[indexPath.row].daysCount) дней"
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.width / 2 - 30
        return CGSize(width: width, height: 180)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if typeCourse == .myCreate {
            selectIDCourse = course[indexPath.row].id
            performSegue(withIdentifier: "changeCourse", sender: self)
        }else if typeCourse == .recomend {
            selectCourse = course[indexPath.row]
            performSegue(withIdentifier: "infoCourses", sender: self)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "changeCourse" {
            let vc = segue.destination as! AddInfoAboutCourseVC
            vc.create = false
            vc.idCourse = selectIDCourse
        }else if segue.identifier == "infoCourses" {
            let vc = segue.destination as! InfoCoursesViewController
            vc.course = selectCourse
        }
    }

}
extension CoursesViewController: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""

        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)

        filteredCourse = updatedText.isEmpty ? course : course.filter { courseItem in
            return courseItem.nameCourse.lowercased().contains(updatedText.lowercased())
        }
        emptyCheck()
        catalogCollectionView.reloadData()
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }


}
