//
//  InfoCoursesViewController.swift
//  Courses
//
//  Created by Руслан on 11.07.2024.
//

import UIKit
import SkeletonView
import SDWebImage

class InfoCoursesViewController: UIViewController {

    @IBOutlet weak var similarCourseLbl: UILabel!
    @IBOutlet weak var similarCoursesCollectionView: UICollectionView!
    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet weak var categoryLbl: UILabel!
    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var descriptionView: UIView!
    @IBOutlet weak var rating: UILabel!
    @IBOutlet weak var stackInfo: UIStackView!
    @IBOutlet weak var countDays: UILabel!
    @IBOutlet weak var topScrollConstant: NSLayoutConstraint!
    @IBOutlet weak var cancelBtnAdmin: UIButton!
    @IBOutlet weak var stackBtn: UIStackView!
    @IBOutlet weak var reviewsLbl: UILabel!
    @IBOutlet weak var reviewsConstant: NSLayoutConstraint!
    @IBOutlet weak var similarConstant: NSLayoutConstraint!
    @IBOutlet weak var buyView: UIView!
    @IBOutlet weak var coachName: UILabel!
    @IBOutlet weak var reviewsCollectionView: UICollectionView!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var countBuyer: UILabel!
    @IBOutlet weak var dateCreate: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var im: UIImageView!
    @IBOutlet weak var btnView: UIButton!

    private let errorView = ErrorView(frame: CGRect(x: 25, y: 54, width: UIScreen.main.bounds.width - 50, height: 70))
    private var startPosition = CGPoint()

    var course = Course()
    var similarCourse = [Course]()
    var reviews = [Reviews]()
    var interface: InfoCourses = .nothing
    var price: Int = 0 {
        didSet {
            priceLbl.text = "₽\(price)"
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        reviewsCollectionView.delegate = self
        reviewsCollectionView.dataSource = self
        similarCoursesCollectionView.delegate = self
        similarCoursesCollectionView.dataSource = self
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
    
    private func getSimilarCourses() {
        Task {
            similarCourse = try await Course().getAllCourses(categoryID: course.category.id)
            deleteSelectCoursesInSimilar()
            designSimilarCourse()
            similarCoursesCollectionView.reloadData()
            changeCollectionViewHeight()
            similarCoursesCollectionView.invalidateIntrinsicContentSize()
            self.view.layoutIfNeeded()
        }
    }
    
    private func designSimilarCourse() {
        if similarCourse.isEmpty {
            similarCourseLbl.isHidden = true
        }
    }
    
    private func deleteSelectCoursesInSimilar() {
        guard similarCourse.isEmpty == false else { return }
        for x in 0...similarCourse.count - 1 {
            if course.id == similarCourse[x].id {
                similarCourse.remove(at: x)
                return
            }
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
        price = course.price
        descriptionText.text = course.description
        dateCreate.text = course.dataCreated
        rating.text = "\(course.rating)"
        countDays.text = "\(course.daysCount)"
        name.text = course.nameCourse
        coachName.text = course.author.userName
        im.sd_setImage(with: course.imageURL)
        countBuyer.text = "\(course.countBuyer)"
        categoryLbl.text = course.category.nameCategory
        userAvatar.sd_setImage(with: course.author.avatarURL)
        interfaceCheck()
        interfaceDesign()
        getComments()
        getSimilarCourses()
    }
    
    private func sceletonAnimatedStart() {
        reviewsCollectionView.isSkeletonable = true
        reviewsCollectionView.showAnimatedGradientSkeleton(usingGradient: SkeletonGradient(baseColor: UIColor.lightBlackMain))
        name.isSkeletonable = true
        name.linesCornerRadius = 5
        name.skeletonTextNumberOfLines = 2
        name.showAnimatedGradientSkeleton(usingGradient: SkeletonGradient(baseColor: UIColor.lightBlackMain))
        descriptionView.isSkeletonable = true
        descriptionView.skeletonCornerRadius = 15
        descriptionView.showAnimatedGradientSkeleton(usingGradient: SkeletonGradient(baseColor: UIColor.lightBlackMain))
        stackInfo.isSkeletonable = true
        stackInfo.skeletonCornerRadius = 15
        stackInfo.showAnimatedGradientSkeleton(usingGradient: SkeletonGradient(baseColor: UIColor.lightBlackMain))

        stackBtn.isHidden = true
        dateCreate.isHidden = true
        categoryLbl.isHidden = true
    }
    
    private func sceletonAnimatedStop() {
        reviewsCollectionView.hideSkeleton(transition: .none)
        im.hideSkeleton(transition: .none)
        name.hideSkeleton(transition: .none)
        descriptionView.hideSkeleton(transition: .none)
        stackInfo.hideSkeleton(transition: .none)
        stackBtn.isHidden = false
        dateCreate.isHidden = false
        categoryLbl.isHidden = false
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
            buyView.isHidden = false
            cancelBtnAdmin.isHidden = true
            stackBtn.distribution = .fill
        case .review:
            btnView.setTitle("Оставить отзыв", for: .normal)
            btnView.isHidden = false
            cancelBtnAdmin.isHidden = true
            buyView.isHidden = true
            stackBtn.distribution = .fill
        case .send:
            btnView.setTitle("Отправить на проверку", for: .normal)
            btnView.isHidden = false
            cancelBtnAdmin.isHidden = true
            buyView.isHidden = true
            stackBtn.distribution = .fill
        case .nothing:
            btnView.isHidden = true
            cancelBtnAdmin.isHidden = true
            buyView.isHidden = true
            stackBtn.distribution = .fill
        case .adminVerification:
            btnView.setTitle("Подтвердить", for: .normal)
            btnView.isHidden = false
            cancelBtnAdmin.isHidden = false
            buyView.isHidden = true
            stackBtn.distribution = .fillEqually
        }
    }
    
    private func myCourse() -> Bool {
        if User.info.id == course.author.id {
            btnView.isHidden = true
            return true
        }else {
            return false
        }
    }

    private func changeCollectionViewHeight() {
        let heightConstant = -self.view.safeAreaInsets.top
        topScrollConstant.constant = heightConstant
        reviewsConstant.constant = reviewsCollectionView.contentSize.height
        similarConstant.constant = similarCoursesCollectionView.contentSize.height
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
            }
        }
    }
    
    private func openTinkoffKassa() {
        Task {
            let email = try await getEmail()
            Payment().configure(self, email: email, price: price) { result in
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
        }else if interface == .bought {
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
            vc.idCoach = course.author.id
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
        if collectionView == reviewsCollectionView {
            return reviews.count
        }else {
            return similarCourse.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == reviewsCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "reviews", for: indexPath) as! ReviewsCollectionViewCell
            cell.avatar.sd_setImage(with: reviews[indexPath.row].authorAvatar)
            cell.descriptionText.text = reviews[indexPath.row].text
            cell.data.text = reviews[indexPath.row].date
            cell.name.text = reviews[indexPath.row].author
            return cell
        }else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "course", for: indexPath) as! CoursesCollectionViewCell
            cell.image.sd_setImage(with: similarCourse[indexPath.row].imageURL)
            cell.nameAuthor.text = similarCourse[indexPath.row].author.userName
            cell.nameCourse.text = similarCourse[indexPath.row].nameCourse
            cell.price.text = "\(similarCourse[indexPath.row].price)₽"
            cell.rating.text = "\(similarCourse[indexPath.row].rating)"
            cell.daysCount.text = "\(similarCourse[indexPath.row].daysCount) этапов"
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == similarCoursesCollectionView {
            openCourse(courseID: similarCourse[indexPath.row].id)
        }
    }
    
    private func openCourse(courseID: Int) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(identifier: "InfoCoursesViewController") as? InfoCoursesViewController else { return }
        
        vc.course.id = courseID
        navigationController?.pushViewController(vc, animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == reviewsCollectionView {
            let textView = UITextView()
            textView.font = UIFont(name: "Commissioner-Medium", size: 12)!
            textView.text = reviews[indexPath.row].text
            let textSize = textView.sizeThatFits(CGSize(width: collectionView.bounds.width, height: CGFloat.greatestFiniteMagnitude))
            return CGSize(width: collectionView.bounds.width, height: textSize.height + 55)
        }else {
            let width = UIScreen.main.bounds.width / 2 - 30
            return CGSize(width: width, height: 180)
        }
    }


}
