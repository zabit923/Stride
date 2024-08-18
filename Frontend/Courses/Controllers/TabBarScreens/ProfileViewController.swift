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
    
    var user: UserStruct = User.info {
        didSet {
            addProfile()
        }
    }
    
    var courses = [Course]()
    var selectCourseID = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        coursesCollectionView.delegate = self
        coursesCollectionView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        design()
    }
    
    func design() {
        Task {
            user = try await User().getMyInfo()
            courses = try await Courses().getMyCreateCourses()
            coursesCollectionView.reloadData()
        }
    }
    
    private func addProfile() {
        characteristic.text = user.coach.description
        name.text = "\(user.surname) \(user.name)"
        rating.text = "\(0.0)"
        coursesCount.text = "\(0)"
        if let avatar = user.avatarURL {
            self.avatar.sd_setImage(with: avatar)
        }
    }
    
    
}

extension ProfileViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return courses.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "course", for: indexPath) as! CoursesCollectionViewCell
        cell.image.sd_setImage(with: courses[indexPath.row].imageURL)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectCourseID = courses[indexPath.row].id
        performSegue(withIdentifier: "changeCourse", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "changeCourse" {
            let vc = segue.destination as! AddInfoAboutCourseVC
            vc.create = false
            vc.idCourse = selectCourseID
        }
    }
   
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = UIScreen.main.bounds.width / 3 - 2
        return CGSize(width: size, height: size)
    }
    
}
