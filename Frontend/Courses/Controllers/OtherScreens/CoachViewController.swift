//
//  CoachViewController.swift
//  Courses
//
//  Created by Руслан on 04.08.2024.
//

import Foundation
import UIKit

class CoachViewController: UIViewController {
    
    @IBOutlet weak var coursesCollectionView: UICollectionView!
    @IBOutlet weak var desc: UILabel!
    @IBOutlet weak var rating: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var countCourses: UILabel!
    @IBOutlet weak var avatar: UIImageView!
    
    private var user = UserStruct()
    private var courses = [Course]()
    var idCoach = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        design()
        coursesCollectionView.dataSource = self
        coursesCollectionView.delegate = self
    }
    
    private func design() {
        getCoachInfo()
        getCoachCourses()
    }
    
    private func getCoachInfo() {
        Task {
            user = try await User().getUserByID(id: idCoach)
            avatar.sd_setImage(with: user.avatarURL)
            name.text = "\(user.name) \(user.surname)"
            desc.text = user.coach.description
            rating.text = "0.0"
            countCourses.text = "0"
        }
    }
    
    private func getCoachCourses() {
        Task {
            courses = try await Courses().getCoursesByUserID(id: idCoach)
            coursesCollectionView.reloadData()
        }
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
extension CoachViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return courses.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "course", for: indexPath) as! CoursesCollectionViewCell
        cell.image.sd_setImage(with: courses[indexPath.row].imageURL)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = UIScreen.main.bounds.width / 3 - 3
        return CGSize(width: size, height: size)
    }
    
    
    
}
