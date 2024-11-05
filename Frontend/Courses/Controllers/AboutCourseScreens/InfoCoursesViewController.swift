//
//  InfoCoursesViewController.swift
//  Courses
//
//  Created by Руслан on 11.07.2024.
//

import UIKit
import SkeletonView

class InfoCoursesViewController: UIViewController {

    @IBOutlet weak var cancelBtnAdmin: UIButton!
    @IBOutlet weak var stackBtn: UIStackView!
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
    var interface: InfoCourses = .nothing


    override func viewDidLoad() {
        super.viewDidLoad()
        reviewsCollectionView.delegate = self
        reviewsCollectionView.dataSource = self
        startPosition = errorView.center
        view.addSubview(errorView)
        errorView.isHidden = true
        getCourse()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        changeCollectionViewHeight()
    }

    private func getCourse() {
        sceletonAnimatedStart()
        Task {
            course = try await Course().getCoursesByID(id: course.id)
            design()
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
        sceletonAnimatedStop()
        price.text = "\(course.price)"
        descriptionText.text = course.description
        dateCreate.text = course.dataCreated
        name.text = course.nameCourse
        coachName.setTitle(course.nameAuthor, for: .normal)
        im.sd_setImage(with: course.imageURL)
        countBuyer.text = "\(course.countBuyer)"
        interfaceCheck()
        interfaceDesign()
        getComments()
    }
    
    private func sceletonAnimatedStart() {
        reviewsCollectionView.isSkeletonable = true
        reviewsCollectionView.showAnimatedGradientSkeleton(usingGradient: SkeletonGradient(baseColor: UIColor.lightBlackMain))
        im.isSkeletonable = true
        im.showAnimatedGradientSkeleton(usingGradient: SkeletonGradient(baseColor: UIColor.lightBlackMain))
        name.isSkeletonable = true
        name.linesCornerRadius = 5
        name.showAnimatedGradientSkeleton(usingGradient: SkeletonGradient(baseColor: UIColor.lightBlackMain))
        descriptionText.isSkeletonable = true
        descriptionText.linesCornerRadius = 5
        descriptionText.skeletonTextNumberOfLines = 5
        descriptionText.showAnimatedGradientSkeleton(usingGradient: SkeletonGradient(baseColor: UIColor.lightBlackMain))

        stackBtn.isHidden = true
    }
    
    private func sceletonAnimatedStop() {
        reviewsCollectionView.hideSkeleton(transition: .none)
        im.hideSkeleton(transition: .none)
        name.hideSkeleton(transition: .none)
        descriptionText.hideSkeleton(transition: .none)
        stackBtn.isHidden = false
    }

    private func interfaceCheck() {
        guard interface != .adminVerification else { return }
        
        if myCourse() == true {
            switch course.verification {
            case .proccessVerificate:
                interface = .nothing
            case .noneVerificate:
                interface = .send
            case .proccess:
                interface = .send
            case .verificate:
                interface = .nothing
            }
            return
        }

        if course.isBought == true {
            if course.myRating == 0 {
                interface = .review
                return
            }else {
                interface = .nothing
                return
            }
        }else {
            interface = .bought
            return
        }
    }
    
    private func interfaceDesign() {
        switch interface {
        case .bought:
            buyView.setTitle("Купить", for: .normal)
            buyView.isHidden = false
            priceView.isHidden = false
            cancelBtnAdmin.isHidden = true
            stackBtn.distribution = .fill
        case .review:
            buyView.setTitle("Оставить отзыв", for: .normal)
            priceView.isHidden = true
            buyView.isHidden = false
            cancelBtnAdmin.isHidden = true
            stackBtn.distribution = .fill
        case .send:
            buyView.setTitle("Отправить на проверку", for: .normal)
            buyView.isHidden = false
            cancelBtnAdmin.isHidden = true
            stackBtn.distribution = .fill
        case .nothing:
            buyView.isHidden = true
            priceView.isHidden = true
            cancelBtnAdmin.isHidden = true
            stackBtn.distribution = .fill
        case .adminVerification:
            buyView.setTitle("Подтвердить", for: .normal)
            buyView.isHidden = false
            priceView.isHidden = true
            cancelBtnAdmin.isHidden = false
            stackBtn.distribution = .fillEqually
        }
    }
    
    private func myCourse() -> Bool {
        if User.info.id == course.idAuthor {
            buyView.isHidden = true
            priceView.isHidden = true
            return true
        }else {
            return false
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
            buyView.isEnabled = false
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
                self.buyView.isEnabled = true
            }
        }
    }
    
    private func getEmail() async throws -> String {
        let email = try await User().getMyInfo().email
        return email
    }
    
    private func sendCoursesVerification() {
        Task {
            do {
                try await Course().sendCoursesVerification(idCourse: course.id)
                errorView.configureSuccess(title: "Успешно", description: "Проверим в течение 48 часов")
                errorView.isHidden = false
                interfaceCheck()
            }catch {
                errorView.configure(title: "Ошибка", description: "Попробуйте позже")
                errorView.isHidden = false
            }
        }
    }
    
    private func successVerificationCourseAdmin() {
        Task {
            do {
                try await Admin().successCourses(idCourses: course.id)
                let adminMainVC = navigationController!.viewControllers[navigationController!.viewControllers.count - 4]
                navigationController?.popToViewController(adminMainVC, animated: true)

            }catch {
                errorView.configure(title: "Ошибка", description: "Попробуйте позже")
                errorView.isHidden = false
            }
        }
    }
    
    private func cancelVerificationCourseAdmin() {
        Task {
            do {
                try await Admin().cancelCourses(idCourses: course.id)
                navigationController?.popViewController(animated: true)
            }catch {
                errorView.configure(title: "Ошибка", description: "Попробуйте позже")
                errorView.isHidden = false
            }
        }
    }

    @IBAction func coach(_ sender: UIButton) {
        performSegue(withIdentifier: "coach", sender: self)
    }
    
    
    @IBAction func buy(_ sender: UIButton) {
        if interface == .review {
            performSegue(withIdentifier: "goToAddReview", sender: self)
        }else if interface == .bought{
            openTinkoffKassa()
        }else if interface == .send {
            sendCoursesVerification()
        }else if interface == .adminVerification {
            if sender.tag == 0 {
                successVerificationCourseAdmin()
            }else {
                cancelVerificationCourseAdmin()
            }
        }
    }
    
    
    

    @IBAction func share(_ sender: UIButton) {
        let link = DeepLinksManager.getLinkAboutCourse(idCourse: course.id)
        DeepLinksManager.openShareViewController(url: link, self)
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
