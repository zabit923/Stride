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
    
    var course = [Course]()
    var customView: UIView!
    var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myCoursesCollectionView.delegate = self
        myCoursesCollectionView.dataSource = self
    }

    @IBAction func search(_ sender: UIButton) {
        customView.isHidden = true
    }
}

extension MyCoursesViewController: UICollectionViewDelegate, UICollectionViewDataSource {
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
        cell.progressInDays.text = "\(course[indexPath.row].progressInDays)/\(course[indexPath.row].daysCount)"
        cell.progressInPercents.text = "\(course[indexPath.row].progressInPercents)%"
        cell.progressVIew.progress = Float(course[indexPath.row].progressInPercents / 100)
        return cell
    }
}
