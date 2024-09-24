//
//  InfoCoursesViewController.swift
//  Courses
//
//  Created by Руслан on 11.07.2024.
//

import UIKit

class InfoCoursesViewController: UIViewController {

    @IBOutlet weak var reviewsLbl: UILabel!
    @IBOutlet weak var reviewsConstant: NSLayoutConstraint!
    @IBOutlet weak var coachName: UIButton!
    @IBOutlet weak var reviewsCollectionView: UICollectionView!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var countBuyer: UILabel!
    @IBOutlet weak var dateCreate: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var priceView: UIView!
    @IBOutlet weak var im: UIImageView!
    @IBOutlet weak var buyView: UIButton!

    private let errorView = ErrorView(frame: CGRect(x: 25, y: 54, width: UIScreen.main.bounds.width - 50, height: 70))
    private var startPosition = CGPoint()

    var course = Course()
    var reviews = [Reviews]()
    var buy: Bool?


    override func viewDidLoad() {
        super.viewDidLoad()
        reviewsCollectionView.delegate = self
        reviewsCollectionView.dataSource = self
        startPosition = errorView.center
        deepLinkGetCourse()
        buyOrNextDesign()
        getComments()
        design()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        changeCollectionViewHeight()
    }

    private func getCourse() {
        Task {
            course = try await Course().getCoursesByID(id: course.id)
            design()
            reviewHiddenBtn()
        }
    }

    private func getComments() {
        Task {
            reviews = try await Comments().getComments(courseID: course.id)
            reviewsCollectionView.reloadData()
            changeCollectionViewHeight()
            checkReviewsCount()
            reviewsCollectionView.invalidateIntrinsicContentSize()
            self.view.layoutIfNeeded()
        }
    }

    private func checkReviewsCount() {
        if reviews.isEmpty {
            reviewsLbl.text = "Нет отзывов"
        }else {
            reviewsLbl.text = "Отзывы"
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
    
    private func deepLinkGetCourse() {
        if DeepLinksManager.isLink {
            DeepLinksManager.isLink = false
            getCourse()
            if course.isBought {
                buy = false
            }else {
                buy = true
            }
            buyOrNextDesign()
        }
    }

    private func buyOrNextDesign() {
        if buy == false {
            buyView.setTitle("Оставить отзыв", for: .normal)
            buyView.isHidden = true
            getCourse()
            priceView.isHidden = true
        }else {
            buyView.setTitle("Купить", for: .normal)
            buyView.isHidden = false
            priceView.isHidden = false
        }
    }

    private func reviewHiddenBtn() {
        if course.myRating == 0 {
            buyView.isHidden = false
        }else {
            buyView.isHidden = true
        }
    }

    private func changeCollectionViewHeight() {
        reviewsConstant.constant = reviewsCollectionView.contentSize.height
        self.view.layoutIfNeeded()
    }

    private func buyCourseSuccesed() {
        Task {
            do {
                try await Course().buyCourse(id: course.id)
                performSegue(withIdentifier: "goCourse", sender: self)
            }catch ErrorNetwork.runtimeError(let error) {
                errorView.isHidden = false
                errorView.configure(title: "Ошибка", description: error)
                view.addSubview(errorView)
                buyView.isEnabled = true
            }
        }
    }
    
    private func openTinkoffKassa() {
        Task {
            guard let priceInt = Int(price.text!) else { return }
            let email = try await getEmail()
            Payment().configure(self, email: email, price: priceInt) { result in
                switch result {
                case .succeeded(_):
                    self.buyCourseSuccesed()
                case .failed(_):
                    break
                case .cancelled(_):
                    break
                }
            }
        }
    }
    
    private func getEmail() async throws -> String {
        let email = try await User().getMyInfo().email
        return email
    }

    @IBAction func coach(_ sender: UIButton) {
        performSegue(withIdentifier: "coach", sender: self)
    }
    
    
    @IBAction func buy(_ sender: UIButton) {
        if buy == false {
            performSegue(withIdentifier: "goToAddReview", sender: self)
        }else{
            buyView.isEnabled = false
            openTinkoffKassa()
            buyView.isEnabled = true
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
        }else if segue.identifier == "goToAddReview" {
            let vc = segue.destination as! AddReviewViewController
            vc.idCourse = course.id
        }
    }

    @IBAction func swipe(_ sender: UIPanGestureRecognizer) {
        errorView.swipe(sender: sender, startPosition: startPosition)
    }

}
extension InfoCoursesViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return reviews.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "reviews", for: indexPath) as! ReviewsCollectionViewCell
        cell.avatar.sd_setImage(with: reviews[indexPath.row].authorAvatar)
        cell.descriptionText.text = reviews[indexPath.row].text
        cell.data.text = reviews[indexPath.row].date
        cell.name.text = reviews[indexPath.row].author
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let textView = UITextView()
        textView.font = UIFont(name: "Commissioner-Medium", size: 12)!
        textView.text = reviews[indexPath.row].text
        let textSize = textView.sizeThatFits(CGSize(width: collectionView.bounds.width, height: CGFloat.greatestFiniteMagnitude))
        return CGSize(width: collectionView.bounds.width, height: textSize.height + 30)
    }


}
