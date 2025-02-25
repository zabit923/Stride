//
//  CoachViewController.swift
//  Courses
//
//  Created by Руслан on 04.08.2024.
//
import UIKit
import SDWebImage
import SkeletonView

class CoachViewController: UIViewController {

    @IBOutlet weak var characteristic: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var rating: UILabel!
    @IBOutlet weak var ratingBottom: UILabel!
    @IBOutlet weak var coursesCount: UILabel!
    @IBOutlet weak var coursesCountBottom: UILabel!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var coursesCollectionView: UICollectionView!

    private var user: UserStruct = User.info {
        didSet {
            sceletonAnimatedStop()
            addProfile()
        }
    }

    var courses = [Course]()
    var idCoach = 0
    var selectCourse = Course()

    override func viewDidLoad() {
        super.viewDidLoad()
        coursesCollectionView.delegate = self
        coursesCollectionView.dataSource = self
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        design()
    }

    func design() {
        Task {
            sceletonAnimatedStart()
            try await getCoachInfo()
            try await getCoachCourses()
            coursesCollectionView.reloadData()
        }
    }

    private func getCoachInfo() async throws {
        user = try await User().getUserByID(id: idCoach)
    }

    private func getCoachCourses() async throws {
        courses = try await Course().getCoursesByUserID(id: idCoach)
        coursesCount.text = "\(courses.count)"
        rating.text = "\(averageRating())"
        coursesCollectionView.reloadData()
    }

    private func averageRating() -> Float {
        var ratingSumm: Float = 0.0
        var count = 0
        for course in courses {
            if course.rating != 0.0 {
                ratingSumm += course.rating
                count += 1
            }
        }
        let average = Float(ratingSumm) / Float(count)
        if average.isNaN {
            return 0.0
        }else {
            return average
        }
    }

    private func sceletonAnimatedStart() {
        coursesCollectionView.isSkeletonable = true
        coursesCollectionView.showAnimatedGradientSkeleton(usingGradient: SkeletonGradient(baseColor: UIColor.lightBlackMain))
        avatar.isSkeletonable = true
        avatar.showAnimatedGradientSkeleton(usingGradient: SkeletonGradient(baseColor: UIColor.lightBlackMain))
        characteristic.isSkeletonable = true
        characteristic.linesCornerRadius = 5
        characteristic.skeletonTextNumberOfLines = 3
        characteristic.showAnimatedGradientSkeleton(usingGradient: SkeletonGradient(baseColor: UIColor.lightBlackMain))
        rating.isSkeletonable = true
        rating.linesCornerRadius = 5
        rating.skeletonTextNumberOfLines = 2
        rating.showAnimatedGradientSkeleton(usingGradient: SkeletonGradient(baseColor: UIColor.lightBlackMain))
        coursesCount.isSkeletonable = true
        coursesCount.linesCornerRadius = 5
        coursesCount.skeletonTextNumberOfLines = 2
        coursesCount.showAnimatedGradientSkeleton(usingGradient: SkeletonGradient(baseColor: UIColor.lightBlackMain))
        name.isSkeletonable = true
        name.linesCornerRadius = 5
        name.skeletonTextNumberOfLines = 1
        name.showAnimatedGradientSkeleton(usingGradient: SkeletonGradient(baseColor: UIColor.lightBlackMain))

        ratingBottom.isHidden = true
        coursesCountBottom.isHidden = true
    }

    private func sceletonAnimatedStop() {
        coursesCollectionView.hideSkeleton(transition: .none)
        avatar.hideSkeleton(transition: .none)
        characteristic.hideSkeleton(transition: .none)
        rating.hideSkeleton(transition: .none)
        coursesCount.hideSkeleton(transition: .none)
        name.hideSkeleton(transition: .none)
        ratingBottom.isHidden = false
        coursesCountBottom.isHidden = false
    }

    private func addProfile() {
        name.text = "\(user.name) \(user.surname)"
        characteristic.text = user.coach.description
        if let avatar = user.avatarURL {
            self.avatar.sd_setImage(with: avatar)
        }
    }

    @IBAction func back(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

}

extension CoachViewController: SkeletonCollectionViewDelegate, SkeletonCollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> SkeletonView.ReusableCellIdentifier {
        return "course"
    }


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return courses.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "course", for: indexPath) as! CoursesCollectionViewCell
        cell.image.sd_setImage(with: courses[indexPath.row].imageURL)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectCourse = courses[indexPath.row]
        performSegue(withIdentifier: "info", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "info" {
            let vc = segue.destination as! InfoCoursesViewController
            vc.course = selectCourse
        }
        
    }


    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = UIScreen.main.bounds.width / 3 - 2
        return CGSize(width: size, height: size)
    }

}
