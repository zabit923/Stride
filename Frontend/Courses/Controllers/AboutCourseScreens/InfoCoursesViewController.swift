//
//  InfoCoursesViewController.swift
//  Courses
//
//  Created by Руслан on 11.07.2024.
//

import UIKit

class InfoCoursesViewController: UIViewController {

    @IBOutlet weak var reviewsConstant: NSLayoutConstraint!
    @IBOutlet weak var coachName: UIButton!
    @IBOutlet weak var reviewsCollectionView: UICollectionView!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var countBuyer: UILabel!
    @IBOutlet weak var dateCreate: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var im: UIImageView!
    
    var course = Course()
    var reviews = [Reviews]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reviewsCollectionView.delegate = self
        reviewsCollectionView.dataSource = self
        self.view.layoutSubviews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        getComments()
        design()
    }
    
    private func getComments() {
        Task {
            reviews = try await Comments().getComments(courseID: course.id)
            reviewsCollectionView.reloadData()
            changeCollectionViewHeight()
        }
    }
    
    private func design() {
        price.text = "\(course.price)"
        descriptionText.text = course.description
        dateCreate.text = course.dataCreated
        name.text = course.nameCourse
        coachName.setTitle(course.nameAuthor, for: .normal)
        im.sd_setImage(with: course.imageURL)
        countBuyer.text = "\(course.countBuyer)"
    }
    
    private func changeCollectionViewHeight() {
        reviewsConstant.constant = reviewsCollectionView.contentSize.height
    }
    
    @IBAction func coach(_ sender: UIButton) {
        performSegue(withIdentifier: "coach", sender: self)
    }
    
    @IBAction func buy(_ sender: UIButton) {
        Task {
            do {
                try await Courses().buyCourse(id: course.id)
                performSegue(withIdentifier: "goCourse", sender: self)
            }catch {
                print("Error buy course")
            }
        }
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "coach" {
            let vc = segue.destination as! CoachViewController
            vc.idCoach = course.idAuthor
        }else if segue.identifier == "goCourse" {
            let vc = segue.destination as! ModulesCourseViewController
            vc.idCourse = course.id
        }
        
    }
    
}
extension InfoCoursesViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return reviews.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "reviews", for: indexPath) as! ReviewsCollectionViewCell
        cell.avatar.image = UIImage.defaultLogo
        cell.descriptionText.text = reviews[indexPath.row].text
        cell.data.text = reviews[indexPath.row].date
        cell.name.text = reviews[indexPath.row].author
        return cell
    }
    
    
    
}
