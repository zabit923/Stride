//
//  CoursesViewController.swift
//  Courses
//
//  Created by Руслан on 02.07.2024.
//

import UIKit
import SDWebImage

class CoursesViewController: UIViewController {

    @IBOutlet weak var catalogCollectionView: UICollectionView!
    
    var course = [Course]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        catalogCollectionView.delegate = self
        catalogCollectionView.dataSource = self
        
    }
    
    
}
extension CoursesViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return course.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "course", for: indexPath) as! CoursesCollectionViewCell
        cell.image.sd_setImage(with: URL(string: course[indexPath.row].image))
        cell.nameAuthor.text = course[indexPath.row].nameAuthor
        cell.nameCourse.text = course[indexPath.row].nameCourse
        cell.price.text = "\(course[indexPath.row].price)"
        cell.rating.text = "\(course[indexPath.row].rating)"
        return cell
    }
    
    
}
