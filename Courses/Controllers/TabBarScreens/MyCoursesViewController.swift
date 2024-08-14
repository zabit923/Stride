//
//  MyCoursesViewController.swift
//  Courses
//
//  Created by Ибрагимов Эльдар on 02.07.2024.
//

import UIKit
import SDWebImage

class MyCoursesViewController: UIViewController {

    @IBOutlet weak var myCoursesCollectionView: UICollectionView!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewForSearch: UIView!
    @IBOutlet weak var searchBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var textField: UITextField!
    
    var course = [Course]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myCoursesCollectionView.delegate = self
        myCoursesCollectionView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        design()
    }
    
    func design() {
        cancelBtn.isHidden = true
        viewForSearch.isHidden = true
        let font = UIFont(name: "Commissioner-SemiBold", size: 12)
        textField.attributedPlaceholder = NSAttributedString(string: "Поиск...", attributes: [NSAttributedString.Key.foregroundColor: UIColor.grayMain, NSAttributedString.Key.font: font!])
        getMyBoughtCourses()
    }
    
    private func getMyBoughtCourses() {
        Task {
            course = try await Courses().getBoughtCourses()
            print(course)
            myCoursesCollectionView.reloadData()
        }
    }

    @IBAction func search(_ sender: UIButton) {
        topConstraint.constant = 95
        viewForSearch.isHidden = false
        searchBtn.isHidden = true
        cancelBtn.isHidden = false
        textField.becomeFirstResponder()
    }
    
    @IBAction func cancel(_ sender: UIButton) {
        topConstraint.constant = 30
        viewForSearch.isHidden = true
        searchBtn.isHidden = false
        cancelBtn.isHidden = true
        textField.resignFirstResponder()
    }
    
    
}

extension MyCoursesViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return course.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = myCoursesCollectionView.dequeueReusableCell(withReuseIdentifier: "course", for: indexPath) as! CoursesCollectionViewCell
        cell.image.sd_setImage(with: course[indexPath.row].imageURL)
        cell.nameAuthor.text = "Тренер: \(course[indexPath.row].nameAuthor)"
        cell.nameCourse.text = course[indexPath.row].nameCourse
        cell.rating.text = "\(course[indexPath.row].rating)"
//        cell.progressInDays.text = "\(course[indexPath.row].progressInDays)/\(course[indexPath.row].daysCount)"
//        cell.progressInPercents.text = "\(course[indexPath.row].progressInPercents)%"
//        cell.progressVIew.progress = Float(course[indexPath.row].progressInPercents / 100)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "course", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "course" {
            let vc = segue.destination as! ModulesCourseViewController
        }
        
    }
}
