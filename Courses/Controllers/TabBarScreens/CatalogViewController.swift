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
    
    var categories = [Category]()
    var courses = [Course]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        categoryCollectionView.dataSource = self
        categoryCollectionView.delegate = self
        catalogCollectionView.dataSource = self
        catalogCollectionView.delegate = self
    }
    
    
}

extension CatalogViewController: UICollectionViewDelegate, UICollectionViewDataSource {
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
            cell.image.sd_setImage(with: URL(string: categories[indexPath.row].image))
            cell.nameCategory.text = categories[indexPath.row].nameCategory
            return cell
        }else {
            let cell = catalogCollectionView.dequeueReusableCell(withReuseIdentifier: "course", for: indexPath) as! CoursesCollectionViewCell
            cell.image.sd_setImage(with: URL(string: courses[indexPath.row].image))
            cell.nameAuthor.text = courses[indexPath.row].nameAuthor
            cell.nameCourse.text = courses[indexPath.row].nameCourse
            cell.price.text = "\(courses[indexPath.row].price)"
            cell.rating.text = "\(courses[indexPath.row].rating)"
            cell.daysCount.text = "\(courses[indexPath.row].daysCount)"
            return cell
        }
        
    }
    
    
}
