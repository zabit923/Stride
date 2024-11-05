//
//  AdminCoursesViewController.swift
//  Courses
//
//  Created by Руслан on 28.10.2024.
//

import UIKit

class AdminCoursesViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var courses = [Course]()
    private var selectCourse = Course()
    var isVerificationCourses = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        design()
    }
    
    func design() {
        if isVerificationCourses {
            getCoursesByVerification()
        }else {
            getAllCourses()
        }
    }
    
    func getAllCourses() {
        Task {
            let result = try await Course().getAllCourses()
            courses = result
            collectionView.reloadData()
        }
    }
    
    func getCoursesByVerification() {
        Task {
            let result = try await Admin().getNonVerificationCourses()
            courses = result
            collectionView.reloadData()
        }
    }

    @IBAction func back(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}
extension AdminCoursesViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return courses.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "course", for: indexPath) as! CoursesCollectionViewCell
        cell.image.sd_setImage(with: courses[indexPath.row].imageURL)
        cell.nameAuthor.text = courses[indexPath.row].nameAuthor
        cell.nameCourse.text = courses[indexPath.row].nameCourse
        cell.price.text = "Цена: \(courses[indexPath.row].price)Р"
        cell.rating.text = "\(courses[indexPath.row].rating)"
        cell.daysCount.text = "\(courses[indexPath.row].daysCount) этапов"
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectCourse = courses[indexPath.row]
        performSegue(withIdentifier: "admin", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "admin" {
            let vc = segue.destination as! AddModuleCoursesViewController
            vc.idCourse = selectCourse.id
            vc.role = .adminVerification
        }
        
    }
    
}
