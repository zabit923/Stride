//
//  CoursesViewController.swift
//  Courses
//
//  Created by Руслан on 02.07.2024.
//

import UIKit
import SDWebImage

class CoursesViewController: UIViewController {

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var catalogCollectionView: UICollectionView!
    @IBOutlet weak var textField: UITextField!
    
    private var selectIDCourse = 0
    private var selectCourse = Course()
    var course = [Course]()
    var typeCourse = CourseCatalog.recomend
    
    override func viewDidLoad() {
        super.viewDidLoad()
        catalogCollectionView.delegate = self
        catalogCollectionView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        design()
    }
    
    func design() {
        let font = UIFont(name: "Commissioner-SemiBold", size: 12)
        textField.attributedPlaceholder = NSAttributedString(string: "Поиск...", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: font!])
        getCoursesBecauseTitle()
    }
    
    private func getMyCreateCourses() {
        Task {
            course = try await Courses().getMyCreateCourses()
            catalogCollectionView.reloadData()
        }
    }
    
    private func getRecomendCourses() {
        Task {
            course = try await Courses().getRecomendedCourses()
            catalogCollectionView.reloadData()
        }
    }
    
    private func getCelebrityCourses() {
        Task {
            course = try await Courses().getCoursesByCelebrity()
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
        return course.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "course", for: indexPath) as! CoursesCollectionViewCell
        cell.image.sd_setImage(with: course[indexPath.row].imageURL)
        cell.nameAuthor.text = course[indexPath.row].nameAuthor
        cell.nameCourse.text = course[indexPath.row].nameCourse
        cell.price.text = "\(course[indexPath.row].price)Р"
        cell.rating.text = "\(course[indexPath.row].rating)"
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
