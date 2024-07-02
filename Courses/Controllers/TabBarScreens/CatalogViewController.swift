//
//  ViewController.swift
//  Courses
//
//  Created by Ибрагимов Эльдар on 01.07.2024.
//

import UIKit
import SDWebImage

class CatalogViewController: UIViewController {

    @IBOutlet weak var catalogCollectionView: UICollectionView!
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        categoryCollectionView.dataSource = self
        categoryCollectionView.delegate = self
        catalogCollectionView.dataSource = self
        catalogCollectionView.delegate = self
    }
    
    var categories = [Category]()
    var course = [Course]()
    
}

extension CatalogViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == categoryCollectionView {
            return categories.count
        }else {
            return course.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == categoryCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "category", for: indexPath) as! CategoriesCollectionViewCell
            cell.image.sd_setImage(with: URL(string: categories[indexPath.row].image))
            cell.nameCategory.text = categories[indexPath.row].nameCategory
            return cell
        }else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "course", for: indexPath) as! CoursesCollectionViewCell
            cell.image.sd_setImage(with: URL(string: course[indexPath.row].image))
            cell.nameAuthor.text = course[indexPath.row].nameAuthor
            cell.nameCourse.text = course[indexPath.row].nameCourse
            cell.price.text = "\(course[indexPath.row].price)"
            cell.rating.text = "\(course[indexPath.row].rating)"
            cell.daysCount.text = "\(course[indexPath.row].daysCount)"
            return cell
        }
        
    }
    
    
}
