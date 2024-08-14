//
//  AddModuleCoursesViewController.swift
//  Courses
//
//  Created by Руслан on 14.07.2024.
//

import UIKit

class AddModuleCoursesViewController: UIViewController {

    @IBOutlet weak var nameCourses: UILabel!
    @IBOutlet weak var heightViewDays: NSLayoutConstraint!
    @IBOutlet weak var viewDays: UIView!
    @IBOutlet weak var daysCollectionView: UICollectionView!
    @IBOutlet weak var modulesCollectionView: UICollectionView!
    
    private let layout = PageModuleLayout()
    private var scaleView = false
    private var courseInfo = [CourseInfo]()
    private var selectDay: Int = 0
    var idCourse = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionSettings()
        addCourseInfo()
    }
    
    private func addCourseInfo() {
        var modules = [Modules]()
        courseInfo.append(CourseInfo(day: 1, modules: modules))
        
        Task {
            let course = try await Courses().getDaysInCourse(id: idCourse)
            print(course)
            daysCollectionView.reloadData()
            modulesCollectionView.reloadData()
        }
    }
    
    private func collectionSettings() {
        daysCollectionView.delegate = self
        daysCollectionView.dataSource = self
        modulesCollectionView.delegate = self
        modulesCollectionView.dataSource = self
        
        layout.pageWidth = 350
        layout.itemSize = CGSize(width: 40, height: 40)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        layout.sectionInset.left = 5
        layout.sectionInset.right = 5
        layout.scrollDirection = .horizontal
        daysCollectionView.collectionViewLayout = layout
        daysCollectionView.decelerationRate = .fast
    }
    
    @IBAction func longClickInView(_ sender: UILongPressGestureRecognizer) {
        if scaleView == false {
            if sender.state == .began {
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            } else if sender.state == .ended {
                UIView.animate(withDuration: 0.5) {
                    self.layout.scrollDirection = .vertical
                    self.daysCollectionView.collectionViewLayout = self.layout
                    self.view.layoutIfNeeded()
                    var size = self.daysCollectionView.contentSize.height + 25
                    if size < 65 {size = 65}
                    self.heightViewDays.constant = size
                }
                scaleView = true
            }
        }else {
            if sender.state == .began {
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            } else if sender.state == .ended {
                UIView.animate(withDuration: 0.5) {
                    self.heightViewDays.constant = 65
                }
                self.layout.scrollDirection = .horizontal
                self.daysCollectionView.collectionViewLayout = self.layout
                self.view.layoutIfNeeded()
                scaleView = false
            }
        }
        
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
extension AddModuleCoursesViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == daysCollectionView {
            return courseInfo.count + 1
        }else {
            if courseInfo.isEmpty == false {
                return courseInfo[selectDay].modules.count + 1
            }else {
                return 1
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Day
        if collectionView == daysCollectionView {
            var cell = collectionView.dequeueReusableCell(withReuseIdentifier: "day", for: indexPath) as! DaysCourseCollectionViewCell
            
            cell.lbl.text = "\(indexPath.row + 1)"
            if selectDay == indexPath.row {
                cell.current()
            }else {
                cell.before()
            }
            // Add +
            if indexPath.row == courseInfo.count {
                cell = collectionView.dequeueReusableCell(withReuseIdentifier: "addDayCell", for: indexPath) as! DaysCourseCollectionViewCell
                return cell
            }
            return cell
        }else {
            // Modules
            var cell = collectionView.dequeueReusableCell(withReuseIdentifier: "module", for: indexPath) as! ModuleCourseCollectionViewCell
        
            // Add +
            if indexPath.row == courseInfo[selectDay].modules.count {
                cell = collectionView.dequeueReusableCell(withReuseIdentifier: "moduleAdd", for: indexPath) as! ModuleCourseCollectionViewCell
                return cell
            }
            
            if courseInfo[selectDay].modules[indexPath.row].image != nil {
                cell = collectionView.dequeueReusableCell(withReuseIdentifier: "module", for: indexPath) as! ModuleCourseCollectionViewCell
                cell.im.image = courseInfo[selectDay].modules[indexPath.row].image
                cell.settingsBtn.addTarget(self, action: #selector(settings), for: .touchUpInside)
                cell.settingsBtn.tag = indexPath.row
            }else {
                cell = collectionView.dequeueReusableCell(withReuseIdentifier: "module2", for: indexPath) as! ModuleCourseCollectionViewCell
                cell.settingsBtn2.addTarget(self, action: #selector(settings), for: .touchUpInside)
                cell.settingsBtn2.tag = indexPath.row
            }
            cell.name.text = courseInfo[selectDay].modules[indexPath.row].name
            cell.time.text = "\(courseInfo[selectDay].modules[indexPath.row].minutes) минут(ы/а)"
            cell.descrLbl.text = courseInfo[selectDay].modules[indexPath.row].description
            
            
            
            
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == daysCollectionView {
            
            if indexPath.row == courseInfo.count {
                courseInfo.append(CourseInfo(day: indexPath.row + 1))
                daysCollectionView.insertItems(at: [IndexPath(item: courseInfo.count - 1, section: 0)])
            }else{
                selectDay = indexPath.row
            }
            modulesCollectionView.reloadData()
            daysCollectionView.reloadData()
        }else {
            
            if indexPath.row == courseInfo[selectDay].modules.count {
                let module = Modules(name: "", minutes: 0, id: indexPath.row)
                courseInfo[selectDay].modules.append(module)
                collectionView.insertItems(at: [IndexPath(item: courseInfo[selectDay].modules.count - 1, section: 0)])
            }else {
                performSegue(withIdentifier: "goToAddCourse2", sender: self)
            }
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.width - 40
        if collectionView == daysCollectionView {
            let result = 40
            return CGSize(width: result, height: result)
        }else {
            return CGSize(width: width, height: 120)
        }
    }
    
    @objc func settings(sender: UIButton) {
        performSegue(withIdentifier: "goToModuleSettings", sender: self)
    }

}