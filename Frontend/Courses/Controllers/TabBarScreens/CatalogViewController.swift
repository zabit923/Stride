//
//  ViewController.swift
//  Courses
//
//  Created by Ибрагимов Эльдар on 01.07.2024.
//

import UIKit
import SDWebImage
import Lottie

class CatalogViewController: UIViewController {

    @IBOutlet weak var instagrampostFilterSegment: UIButton!
    @IBOutlet weak var groupPostFilterSegment: UIButton!
    @IBOutlet weak var loadingMain: LottieAnimationView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var loadingPage: LottieAnimationView!
    @IBOutlet weak var catalogHeight: NSLayoutConstraint!
    @IBOutlet weak var emptyBox: LottieAnimationView!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var search: UITextField!
    @IBOutlet weak var catalogCollectionView: UICollectionView!
    @IBOutlet weak var categoryCollectionView: UICollectionView!

    var categories = [Category]()
    var courses = [Course]()
    private var selectCourse = Course()
    private var selectCategory: Category?
    private var loadingMoreData = false
    private var postFilterSegment: PostSegmented!

    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        categoryCollectionView.dataSource = self
        categoryCollectionView.delegate = self
        catalogCollectionView.dataSource = self
        catalogCollectionView.delegate = self
        search.delegate = self
        postFilterSegment = PostSegmented(firstBtn: groupPostFilterSegment, secondBtn: instagrampostFilterSegment)
        design()
    }
    
    
    private func changeHeightCollection() {
        catalogHeight.constant = catalogCollectionView.contentSize.height
    }
    
    private func design() {
        getCourses()
        getCategories()
        emptySettings()
        loadingPage.play()
        loadingPage.loopMode = .loop
        loadingMain.play()
        loadingMain.loopMode = .loop
    }

    private func getCourses(page: String? = nil) {
        Task {
            if page == nil {
                loadingMain.isHidden = false
            }
            do {
                let results = try await Course().getAllCourses(page: page)
                courses += results
                emptyCheck()
                catalogCollectionView.reloadData()
                loadingMoreData = false
                catalogCollectionView.layoutIfNeeded()
                changeHeightCollection()
                loadingMain.isHidden = true
            }catch {
                loadingMoreData = false
                loadingMain.isHidden = true
            }
        }
    }

    
    
    private func getCoursesByCategory(id: Int) {
        Task {
            courses.removeAll()
            catalogCollectionView.reloadData()
            loadingMain.isHidden = false
            do {
                let results = try await Course().getAllCourses(categoryID: id)
                courses = results
                emptyCheck()
                catalogCollectionView.reloadData()
                loadingMoreData = false
                catalogCollectionView.layoutIfNeeded()
                changeHeightCollection()
                loadingMain.isHidden = true
            }catch {
                loadingMoreData = false
                loadingMain.isHidden = true
            }
        }
    }

    private func getCategories() {
        Task {
            categories = try await Category.getCategories()
            categoryCollectionView.reloadData()
        }
    }

    private func searchCourse(text: String) {
        Task {
            courses = try await Course().searchCourses(text: text, category: selectCategory)
            emptyCheck()
            catalogCollectionView.reloadData()
            loadingPage.isHidden = true
            loadingPage.stop()
            catalogCollectionView.layoutIfNeeded()
            changeHeightCollection()
        }
    }
    
    private func emptyCheck() {
        if courses.isEmpty == false {
            emptyView.isHidden = true
        }else {
            emptyView.isHidden = false
        }
    }
    
    private func emptySettings() {
        emptyBox.contentMode = .scaleToFill
        emptyBox.play()
    }
    
    
    
    @IBAction func filterPost(_ sender: UIButton) {
        if sender == groupPostFilterSegment {
            postFilterSegment.onFirst()
        }else {
            postFilterSegment.onSecond()
        }
        catalogCollectionView.reloadData()
        catalogCollectionView.layoutIfNeeded()
        changeHeightCollection()
    }
    
    @IBAction func tap(_ sender: UITapGestureRecognizer) {
        search.resignFirstResponder()
    }

}

extension CatalogViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == categoryCollectionView {
            return categories.count
        }else {
            return courses.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == categoryCollectionView {
            let cell = categoryCollectionView.dequeueReusableCell(withReuseIdentifier: "category", for: indexPath) as! CategoriesCollectionViewCell
            cell.image.sd_setImage(with: categories[indexPath.row].imageURL)
            cell.nameCategory.text = categories[indexPath.row].nameCategory
            cell.selectCategory(selectCategoryID: selectCategory?.id, categoryID: categories[indexPath.row].id)
            return cell
        }else {
            let cell = catalogCollectionView.dequeueReusableCell(withReuseIdentifier: postFilterSegment.collectionIdentifier, for: indexPath) as! CoursesCollectionViewCell
            cell.image.sd_setImage(with: courses[indexPath.row].imageURL)
            cell.nameAuthor.text = courses[indexPath.row].author.userName
            cell.nameCourse.text = courses[indexPath.row].nameCourse
            cell.price.text = "\(courses[indexPath.row].price)₽"
            cell.rating.text = "\(courses[indexPath.row].rating)"
            cell.daysCount.text = "\(courses[indexPath.row].daysCount) этапов"
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == catalogCollectionView {
            selectCourse = courses[indexPath.row]
            performSegue(withIdentifier: "info", sender: self)
        }else if collectionView == categoryCollectionView {
            if selectCategory?.id == categories[indexPath.row].id {
                loadCourses()
            }else {
                loadCategory(indexPath: indexPath)
            }
        }
    }
    
    private func loadCourses() {
        selectCategory = nil
        courses.removeAll()
        catalogCollectionView.reloadData()
        categoryCollectionView.reloadData()
        if search.text == "" {
            getCourses()
        }else {
            searchCourse(text: search.text!)
        }
    }
    
    private func loadCategory(indexPath: IndexPath) {
        selectCategory = categories[indexPath.row]
        if search.text == "" {
            getCoursesByCategory(id: categories[indexPath.row].id)
        }else {
            searchCourse(text: search.text!)
        }
        categoryCollectionView.reloadData()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == catalogCollectionView {
            if postFilterSegment.selectFirst {
                let width = UIScreen.main.bounds.width / 2 - 30
                return CGSize(width: width, height: 180)
            }else {
                let width = catalogCollectionView.bounds.width
                return CGSize(width: width, height: 180)
            }
        }else {
            return CGSize(width: 100, height: 128)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.scrollView {
            let contentHeight = catalogCollectionView.contentSize.height
            let scrollViewHeight = scrollView.frame.size.height
            let scrollOffset = scrollView.contentOffset.y
            
            guard courses.isEmpty == false else { return }
            let nextURL = courses[courses.count - 1].next
            
            if scrollOffset >= contentHeight - scrollViewHeight && loadingMoreData == false && nextURL != "" {
                loadingPage.isHidden = false
                loadingPage.play()
                loadingMoreData = true
                getCourses(page: nextURL)
            }
            
            checkLastPage(nextURL: nextURL)
        }
    }
    
    private func checkLastPage(nextURL:String?) {
        if nextURL == "" {
            loadingPage.stop()
            loadingPage.isHidden = true
        }
    }


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "info" {
            let vc = segue.destination as! InfoCoursesViewController
            vc.course = selectCourse
        }

    }


}
extension CatalogViewController: UITextFieldDelegate {

    func textFieldDidChangeSelection(_ textField: UITextField) {
        searchCourse(text: textField.text!)
    }

    private func disableSelectCategory() {
        if selectCategory != nil {
            selectCategory = nil
            categoryCollectionView.reloadData()
        }
    }
    
}
