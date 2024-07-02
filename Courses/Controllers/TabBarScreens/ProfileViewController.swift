//
//  ProfileViewController.swift
//  Courses
//
//  Created by Ибрагимов Эльдар on 02.07.2024.
//

import UIKit
import SDWebImage

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var characteristic: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var rating: UILabel!
    @IBOutlet weak var coursesCount: UILabel!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var coursesCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        coursesCollectionView.delegate = self
        coursesCollectionView.dataSource = self
       
    }
    var user: User?
    var courses = [Course]()
}

extension ProfileViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return user!.countCourses
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "course", for: indexPath) as! CoursesCollectionViewCell
        cell.image.sd_setImage(with: URL(string: courses[indexPath.row].image))
        return cell
    }
    
    
}
