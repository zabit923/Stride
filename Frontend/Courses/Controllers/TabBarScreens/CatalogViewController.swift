//
//  ViewController.swift
//  Courses
//
//  Created by Ибрагимов Эльдар on 01.07.2024.
//

import UIKit
import SDWebImage

class CatalogViewController: UIViewController {

    @IBOutlet weak var search: UITextField!
    @IBOutlet weak var catalogCollectionView: UICollectionView!
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    @IBOutlet weak var searchTF: UITextField!
    
    var categories = [Category]()
    var courses = [Course]()
    private var selectCourse = Course()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        categoryCollectionView.dataSource = self
        categoryCollectionView.delegate = self
        catalogCollectionView.dataSource = self
        catalogCollectionView.delegate = self
//        search.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getCourses()
        getCategories()
    }
    
    private func getCourses() {
        Task {
            let results = try await Courses().getAllCourses()
            courses = results
            catalogCollectionView.reloadData()
        }
    }
    
    private func getCategories() {
        Task {
            categories = try await Categories().getCategories()
            categoryCollectionView.reloadData()
        }
    }
    
    private func searchCourse(text: String) {
        Task {
            courses = try await Courses().searchCourses(text: text)
            catalogCollectionView.reloadData()
        }
    }
    
    @IBAction func tap(_ sender: UITapGestureRecognizer) {
        searchTF.resignFirstResponder()
    }
    
}

extension CatalogViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == categoryCollectionView {
            return categories.count
        }else {
            return courses.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == categoryCollectionView {
            let cell = categoryCollectionView.dequeueReusableCell(withReuseIdentifier: "category", for: indexPath) as! CategoriesCollectionViewCell
            cell.image.sd_setImage(with: categories[indexPath.row].imageURL)
            cell.nameCategory.text = categories[indexPath.row].nameCategory
            return cell
        }else {
            let cell = catalogCollectionView.dequeueReusableCell(withReuseIdentifier: "course", for: indexPath) as! CoursesCollectionViewCell
            cell.image.sd_setImage(with: courses[indexPath.row].imageURL)
            cell.nameAuthor.text = courses[indexPath.row].nameAuthor
            cell.nameCourse.text = courses[indexPath.row].nameCourse
            cell.price.text = "Цена: \(courses[indexPath.row].price)Р"
            cell.rating.text = "\(courses[indexPath.row].rating)"
            cell.daysCount.text = "\(courses[indexPath.row].daysCount)"
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == catalogCollectionView {
            selectCourse = courses[indexPath.row]
            performSegue(withIdentifier: "info", sender: self)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == catalogCollectionView {
            let width = UIScreen.main.bounds.width / 2 - 30
            return CGSize(width: width, height: 180)
        }else {
            return CGSize(width: 100, height: 128)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "info" {
            let vc = segue.destination as! InfoCoursesViewController
            vc.course = selectCourse
            vc.buy = true
        }
        
    }
    
    
}
extension CatalogViewController: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        searchCourse(text: textField.text!)
    }
    
}
