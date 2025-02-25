//
//  MyCoursesViewController.swift
//  Courses
//
//  Created by Ибрагимов Эльдар on 02.07.2024.
//

import UIKit
import SDWebImage
import Lottie

class MyCoursesViewController: UIViewController {

    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var emptyBox: LottieAnimationView!
    @IBOutlet weak var loading: LottieAnimationView!
    @IBOutlet weak var myCoursesCollectionView: UICollectionView!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewForSearch: UIView!
    @IBOutlet weak var searchBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var search: UITextField!

    var course = [Course]()
    var filteredCourse = [Course]()
    private var selectIDCourse = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        myCoursesCollectionView.delegate = self
        myCoursesCollectionView.dataSource = self
        search.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        design()
    }

    func design() {
        loadingSettings()
        let font = UIFont(name: "Commissioner-SemiBold", size: 12)
        search.attributedPlaceholder = NSAttributedString(string: "Поиск...", attributes: [NSAttributedString.Key.foregroundColor: UIColor.grayMain, NSAttributedString.Key.font: font!])
        getMyBoughtCourses()
    }

    func procent(completed:Int, countAll: Int) -> Double {
        guard countAll > 0 else { return 100.0 }
        let progress = Double(completed) / Double(countAll)
        return progress * 100

    }

    private func loadingSettings() {
        loading.loopMode = .loop
        loading.contentMode = .scaleToFill
        loading.isHidden = false
        loading.play()
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

    private func getMyBoughtCourses() {
        Task {
            course = try await Course().getBoughtCourses()
            filteredCourse = course
            loading.stop()
            loading.isHidden = true
            emptyCheck()
            myCoursesCollectionView.reloadData()
        }
    }

    @IBAction func search(_ sender: UIButton) {
        topConstraint.constant = 95
        viewForSearch.isHidden = false
        searchBtn.isHidden = true
        cancelBtn.isHidden = false
        search.becomeFirstResponder()
    }

    @IBAction func cancel(_ sender: UIButton) {
        search.text = ""
        filteredCourse = course
        myCoursesCollectionView.reloadData()
        topConstraint.constant = 30
        viewForSearch.isHidden = true
        searchBtn.isHidden = false
        cancelBtn.isHidden = true
        search.resignFirstResponder()
        emptyCheck()
    }

    @IBAction func tap(_ sender: UITapGestureRecognizer) {
        search.resignFirstResponder()
    }

}

extension MyCoursesViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredCourse.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = myCoursesCollectionView.dequeueReusableCell(withReuseIdentifier: "course", for: indexPath) as! CoursesCollectionViewCell
        cell.image.sd_setImage(with: filteredCourse[indexPath.row].imageURL)
        cell.nameAuthor.text = "Тренер: \(filteredCourse[indexPath.row].author.userName)"
        cell.nameCourse.text = filteredCourse[indexPath.row].nameCourse
        cell.rating.text = "\(filteredCourse[indexPath.row].rating)"
        cell.progressInDays.text = "\(filteredCourse[indexPath.row].progressInDays)/\(filteredCourse[indexPath.row].daysCount)"
        let procent = procent(completed: course[indexPath.row].progressInDays, countAll: filteredCourse[indexPath.row].daysCount)
        cell.progressInPercents.text = "\(Int(procent))%"
        cell.progressVIew.setProgress(Float(procent / 100), animated: false)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectIDCourse = filteredCourse[indexPath.row].id
        performSegue(withIdentifier: "course", sender: self)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width - 50, height: 120)
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "course" {
            let vc = segue.destination as! ModulesCourseViewController
            vc.idCourse = selectIDCourse
        }

    }
}
extension MyCoursesViewController: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""

        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)

        filteredCourse = updatedText.isEmpty ? course : course.filter { courseItem in
            return courseItem.nameCourse.lowercased().contains(updatedText.lowercased())
        }
        emptyCheck()
        myCoursesCollectionView.reloadData()
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }


}
