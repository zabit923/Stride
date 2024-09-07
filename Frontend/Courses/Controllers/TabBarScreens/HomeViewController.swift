//
//  HomeViewController.swift
//  Courses
//
//  Created by Руслан on 24.06.2024.
//

import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var celebrityCollectionView: UICollectionView!
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var bannersCollectionView: UICollectionView!
    @IBOutlet weak var imProfile: UIImageView!
    @IBOutlet weak var recomendCollectionView: UICollectionView!

    private var banners = [String]()
    private var recomendCourses = [Course]()
    private var celebrityCourses = [Course]()
    private var celebrities = [UserStruct]()
    private let layout = PageLayout()
    private var selectCourses = Course()
    private var user: UserStruct = User.info {
        didSet {
            addProfile()
        }
    }
    private var startPosition = CGPoint()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadingStart()
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        collectionViewSettings()
        tabbar()
        startPosition = errorView.center
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        design()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let x = (layout.itemSize.width + layout.minimumInteritemSpacing) * 1000000
        bannersCollectionView.setContentOffset(CGPoint(x: x, y: 0), animated: false)
    }
    
    private func loadingStart() {
        performSegue(withIdentifier: "loading", sender: self)
    }
    
    private func getUser() {
        Task {
            user = try await User().getMyInfo()
            self.navigationController?.popToViewController(tabBarController!, animated: false)
        }
    }
    
    private func getCelebrity() {
        Task {
            celebrities = try await User().getCelebreties()
        }
    }
    
    private func getRecomendCourses() {
        Task {
            recomendCourses = try await Courses().getRecomendedCourses()
            recomendCollectionView.reloadData()
        }
    }
    
    private func getCelebrityCourses() {
        Task {
            celebrityCourses = try await Courses().getCoursesByCelebrity()
            celebrityCollectionView.reloadData()
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
    }
    
    private func design() {
        getRecomendCourses()
        getCelebrityCourses()
        getUser()
        getBanners()
    }
    
    private func addProfile() {
        nameLbl.text = "\(user.name) \(user.surname)"
        if let ava = user.avatarURL {
            avatar.sd_setImage(with: ava)
        }
    }
    
    
    private func getBanners() {
        banners.append("first")
        banners.append("second")
        bannersCollectionView.reloadData()
    }
    
    @IBAction func myCourses(_ sender: UIButton) {
        tabBarController?.selectedIndex = 2
    }
    
    @IBAction func coursesFromStars(_ sender: UIButton) {
        errorView.isHidden = false
    }
    
    @IBAction func swipeError(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: errorView)
        switch sender.state {
        case .changed:
            errorView.center = CGPoint(x: errorView.center.x, y: errorView.center.y +  translation.y)
            sender.setTranslation(CGPoint.zero, in: errorView)
        case .ended:
            if errorView.center.y <= 40 {
                self.errorView.isHidden = true
            }
            UIView.animate(withDuration: 0.5) {
                self.errorView.center = self.startPosition
            }
        default:
            break
        }
    }
    


}
extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == bannersCollectionView {
            return Int.max
        }else if collectionView == recomendCollectionView {
            return recomendCourses.count
        }else {
            if celebrities.count <= 6 {
                return celebrities.count
            }else {
                return 6
            }
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
            cell.trener.text = "Тренер: \(recomendCourses[indexPath.row].nameAuthor)"
            cell.rating.text = "\(recomendCourses[indexPath.row].rating)"
            
            return cell
        }else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "celebrity", for: indexPath) as! CelebrityCollectionViewCell
            cell.name.text = celebrities[indexPath.row].name + celebrities[indexPath.row].surname
//            cell.rating.text = "\(celebrities[indexPath.row].rating)"
//            cell.im.sd_setImage(with: celebrities[indexPath.row].imageURL)
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
        }
        
    }
    
}
