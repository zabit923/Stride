//
//  HomeViewController.swift
//  Courses
//
//  Created by Руслан on 24.06.2024.
//

import UIKit
import Lottie

class HomeViewController: UIViewController {
    
    @IBOutlet weak var coachCollectionView: UICollectionView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var celebrityCollectionView: UICollectionView!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var bannersCollectionView: UICollectionView!
    @IBOutlet weak var imProfile: UIImageView!
    @IBOutlet weak var recomendCollectionView: UICollectionView!
    
    private var banners = [String]()
    private var recomendCourses = [Course]()
    private var celebrities = [UserStruct]()
    private let layout = PageLayout()
    private var selectCourses = Course()
    private var user: UserStruct = User.info {
        didSet {
            addProfile()
        }
    }
    private let errorView = ErrorView(frame: CGRect(x: 25, y: 54, width: UIScreen.main.bounds.width - 50, height: 70))
    private var startPosition = CGPoint()
    private let animationView = LottieAnimationView()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadingStart()
        collectionViewSettings()
        tabbar()
        startPosition = errorView.center
        view.addSubview(errorView)
        errorView.isHidden = true
        design()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getUser()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let x = (layout.itemSize.width + layout.minimumInteritemSpacing) * 1000000
        bannersCollectionView.setContentOffset(CGPoint(x: x, y: 0), animated: false)
    }
    
    private func loadingStart() {
        if DeepLinksManager.isLink == false {
            performSegue(withIdentifier: "loading", sender: self)
        }else {
            getCelebrity()
            getRecomendCourses()
        }
    }
    
    
    
    private func getUser() {
        Task {
            user = try await User().getMyInfo()
        }
    }
    
    private func getCelebrity() {
        Task {
            celebrities = try await User().getCelebreties()
            celebrityCollectionView.reloadData()
        }
    }
    
    private func getRecomendCourses() {
        Task {
            recomendCourses = try await Course().getRecomendedCourses()
            recomendCollectionView.reloadData()
        }
    }
    
    private func tabbar() {
        var deleteUser = 3
        if user.role == .coach {
            deleteUser = 4
        }
        self.tabBarController?.viewControllers?.remove(at: deleteUser) // 3 - USER | 4 - COACH
        self.tabBarController?.setViewControllers(self.tabBarController?.viewControllers, animated: false)
    }
    
    
    private func collectionViewSettings() {
        bannersCollectionView.delegate = self
        bannersCollectionView.dataSource = self
        let itemWidth = UIScreen.main.bounds.width - 60
        layout.itemSize = CGSize(width: itemWidth, height: 180)
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 12
        layout.sectionInset.left = 30
        layout.scrollDirection = .horizontal
        bannersCollectionView.collectionViewLayout = layout
        bannersCollectionView.decelerationRate = .fast
        
        recomendCollectionView.delegate = self
        recomendCollectionView.dataSource = self
        let layoutRecomendCollection = PageLayout()
        let itemWidthRecomend = UIScreen.main.bounds.width - 60
        layoutRecomendCollection.itemSize = CGSize(width: itemWidthRecomend, height: 80)
        layoutRecomendCollection.minimumInteritemSpacing = 0
        layoutRecomendCollection.minimumLineSpacing = 20
        layoutRecomendCollection.sectionInset.left = 15
        layoutRecomendCollection.sectionInset.right = 15
        layoutRecomendCollection.scrollDirection = .horizontal
        recomendCollectionView.collectionViewLayout = layoutRecomendCollection
        recomendCollectionView.decelerationRate = .fast
        
        celebrityCollectionView.delegate = self
        celebrityCollectionView.dataSource = self
        coachCollectionView.delegate = self
        coachCollectionView.dataSource = self
    }
    
    private func design() {
        getBanners()
    }
    
    private func addProfile() {
        nameLbl.text = "\(user.name) \(user.surname)"
        avatar.sd_setImage(with: user.avatarURL!)
    }
    
    
    private func getBanners() {
        banners.append("first")
        banners.append("second")
        banners.append("third")
        banners.append("fourth")
        bannersCollectionView.reloadData()
    }
    
    @IBAction func popular(_ sender: UIButton) {
        performSegue(withIdentifier: "popular", sender: self)
    }
    
    @IBAction func myCourses(_ sender: UIButton) {
        tabBarController?.selectedIndex = 2
    }
    
    @IBAction func coursesFromStars(_ sender: UIButton) {
        if celebrities.isEmpty {
            errorView.isHidden = false
            errorView.configureUnavailable(title: "Cкоро", description: "В данный момент недоступно")
        }else {
            performSegue(withIdentifier: "celebrities", sender: self)
        }
    }
    
    @IBAction func swipeError(_ sender: UIPanGestureRecognizer) {
        errorView.swipe(sender: sender, startPosition: startPosition)
    }
    
    
    
}
extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == bannersCollectionView {
            return Int.max
        }else if collectionView == celebrityCollectionView {
            return celebrities.count
        }else if collectionView == recomendCollectionView {
            if recomendCourses.count <= 6 {
                return recomendCourses.count
            }else {
                return 6
            }
        }else {
            return 7
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == bannersCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "banner", for: indexPath) as! BannerCollectionViewCell
            cell.im.image = UIImage(named: banners[indexPath.row % banners.count])
            return cell
        }else if collectionView == recomendCollectionView {
            var cell = collectionView.dequeueReusableCell(withReuseIdentifier: "recomend", for: indexPath) as! RecomendationCollectionViewCell
            
            cell.bottomView.isHidden = false
            if (indexPath.row + 2) % 3 == 0 {
                cell.layer.cornerRadius = 0
            }else if (indexPath.row + 1) % 3 == 1 {
                cell = cornerRadius(view: cell, position: [.layerMaxXMinYCorner, .layerMinXMinYCorner]) as! RecomendationCollectionViewCell
            }else if (indexPath.row + 1) % 3 == 0 {
                cell = cornerRadius(view: cell, position: [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]) as! RecomendationCollectionViewCell
                cell.bottomView.isHidden = true
            }
            
            cell.im.sd_setImage(with: recomendCourses[indexPath.row].imageURL)
            cell.name.text = recomendCourses[indexPath.row].nameCourse
            cell.trener.text = "Тренер: \(recomendCourses[indexPath.row].author.userName)"
            cell.rating.text = "\(recomendCourses[indexPath.row].rating)"
            
            return cell
        }else if collectionView == celebrityCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "celebrity", for: indexPath) as! CelebrityCollectionViewCell
            cell.name.text = "\(celebrities[indexPath.row].name) \(celebrities[indexPath.row].surname)"
            //            cell.rating.text = "\(celebrities[indexPath.row].rating)"
            cell.im.sd_setImage(with: celebrities[indexPath.row].avatarURL)
            return cell
        }else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "coach", for: indexPath) as! CoachCollectionViewCell
            cell.starPosititon(rating: 2.6)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == recomendCollectionView {
            selectCourses = recomendCourses[indexPath.row]
            performSegue(withIdentifier: "infoCourses", sender: self)
        }
    }
    
    
    private func cornerRadius(view: UIView, position: CACornerMask) -> UIView {
        view.clipsToBounds = true
        view.layer.cornerRadius = 15
        view.layer.maskedCorners = position
        return view
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "infoCourses" {
            let vc = segue.destination as! InfoCoursesViewController
            vc.course = selectCourses
        }else if segue.identifier == "allRecomend" {
            let vc = segue.destination as! CoursesViewController
            vc.typeCourse = .recomend
            vc.course = recomendCourses
        }else if segue.identifier == "celebrities" {
            let vc = segue.destination as! CoursesViewController
            vc.typeCourse = .celebrity
        }else if segue.identifier == "popular" {
            let vc = segue.destination as! CoursesViewController
            vc.typeCourse = .popular
        }else if segue.identifier == "loading" {
            let vc = segue.destination as! LoadingStartViewController
            vc.delegate = self
        }
        
        
    }
    
}
extension HomeViewController: LoadingData {
    
    func getData(user: UserStruct, celebrity: [UserStruct], recomended: [Course]) {
        self.user = user
        self.celebrities = celebrity
        self.celebrityCollectionView.reloadData()
        self.recomendCourses = recomended
        self.recomendCollectionView.reloadData()
    }
    
}
