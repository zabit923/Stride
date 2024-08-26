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
    
    private let errorView = ErrorView(frame: CGRect(x: 25, y: 54, width: UIScreen.main.bounds.width - 50, height: 70))
    private var startPosition = CGPoint()
    
    private let layout = PageModuleLayout()
    private var scaleView = false
    private var course = Course()
    private var selectDay: Int = 0
    private var selectModule = Modules(name: "", minutes: 0, id: 0)
    var idCourse = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionSettings()
        startPosition = errorView.center
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addCourseInfo()
    }
    
    private func addCourseInfo() {
        Task {
            course = try await Courses().getDaysInCourse(id: idCourse)
            nameCourses.text = course.nameCourse
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
    
    private func addDay() {
        Task {
            do {
                let id = try await Courses().addDaysInCourse(courseID: idCourse)
                course.courseDays.append(CourseDays(dayID: id, type: .noneSee))
                daysCollectionView.insertItems(at: [IndexPath(item: course.courseDays.count - 1, section: 0)])
            }catch ErrorNetwork.runtimeError(let error) {
                errorView.isHidden = false
                errorView.configure(title: "Ошибка", description: error)
                view.addSubview(errorView)
            }
        }
    }
    
    private func addModule(dayID: Int) {
        Task {
            do {
                let id = try await Courses().addModulesInCourse(dayID: dayID)
                course.courseDays[selectDay].modules.append(Modules(name: "", minutes: 0, id: id))
                modulesCollectionView.insertItems(at: [IndexPath(item: course.courseDays[selectDay].modules.count - 1, section: 0)])
            }catch ErrorNetwork.runtimeError(let error) {
                errorView.isHidden = false
                errorView.configure(title: "Ошибка", description: error)
                view.addSubview(errorView)
            }
        }
    }
    
    private func deleteDay(dayID: Int) {
        Task {
            do {
                try await Courses().deleteDay(dayID: dayID)
                for x in 0...course.courseDays.count - 1 {
                    if course.courseDays[x].dayID == dayID {
                        course.courseDays.remove(at: x)
                        daysCollectionView.reloadData()
                        break
                    }
                }
            }catch ErrorNetwork.runtimeError(let error) {
                errorView.isHidden = false
                errorView.configure(title: "Ошибка", description: error)
                view.addSubview(errorView)
            }
        }
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
    
    @IBAction func swipe(_ sender: UIPanGestureRecognizer) {
        errorView.swipe(sender: sender, startPosition: startPosition)
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
extension AddModuleCoursesViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == daysCollectionView {
            return course.courseDays.count + 1
        }else {
            if course.courseDays.isEmpty == false {
                return course.courseDays[selectDay].modules.count + 1
            }else {
                return 0
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Day
        if collectionView == daysCollectionView {
            var cell = collectionView.dequeueReusableCell(withReuseIdentifier: "day", for: indexPath) as! DaysCourseCollectionViewCell
            cell.lbl.text = "\(indexPath.row + 1)"
            // Add +
            if indexPath.row == course.courseDays.count {
                cell = collectionView.dequeueReusableCell(withReuseIdentifier: "addDayCell", for: indexPath) as! DaysCourseCollectionViewCell
                return cell
            }else {
                cell.delete.isHidden = false
                cell.delete.tag = course.courseDays[indexPath.row].dayID
                cell.delete.addTarget(self, action: #selector(deleteDayBtn), for: .touchUpInside)
            }
            
            if selectDay == indexPath.row {
                cell.current()
                cell.delete.isHidden = true
            }else {
                cell.before()
            }
            return cell
        }else {
            // Modules
            var cell = collectionView.dequeueReusableCell(withReuseIdentifier: "module", for: indexPath) as! ModuleCourseCollectionViewCell
        
            guard course.courseDays.isEmpty == false else { return cell }
            
            // Add +
            if indexPath.row == course.courseDays[selectDay].modules.count {
                cell = collectionView.dequeueReusableCell(withReuseIdentifier: "moduleAdd", for: indexPath) as! ModuleCourseCollectionViewCell
                return cell
            }
            
            if let image = course.courseDays[selectDay].modules[indexPath.row].imageURL {
                cell = collectionView.dequeueReusableCell(withReuseIdentifier: "module", for: indexPath) as! ModuleCourseCollectionViewCell
                cell.im.sd_setImage(with: image)
                cell.settingsBtn.tag = indexPath.row
                cell.settingsBtn.addTarget(self, action: #selector(settings), for: .touchUpInside)
            }else {
                cell = collectionView.dequeueReusableCell(withReuseIdentifier: "module2", for: indexPath) as! ModuleCourseCollectionViewCell
                cell.settingsBtn2.tag = indexPath.row
                cell.settingsBtn2.addTarget(self, action: #selector(settings), for: .touchUpInside)
            }
            cell.name.text = course.courseDays[selectDay].modules[indexPath.row].name
            cell.time.text = "\(course.courseDays[selectDay].modules[indexPath.row].minutes) минут(ы/а)"
            cell.descrLbl.text = course.courseDays[selectDay].modules[indexPath.row].description
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == daysCollectionView {
            
            if indexPath.row == course.courseDays.count {
                addDay()
            }else{
                selectDay = indexPath.row
            }
            modulesCollectionView.reloadData()
            daysCollectionView.reloadData()
        }else {
            
            if indexPath.row == course.courseDays[selectDay].modules.count {
                addModule(dayID: course.courseDays[selectDay].dayID)
            }else {
                selectModule = course.courseDays[selectDay].modules[indexPath.row]
                performSegue(withIdentifier: "goToAddCourse2", sender: self)
            }
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToAddCourse2" {
            let vc = segue.destination as! AddCourseViewController
            vc.module = selectModule
            vc.nameCourse = course.nameCourse
        }else if segue.identifier == "goToModuleSettings" {
            let vc = segue.destination as! AddInfoAboutModuleViewController
            vc.module = selectModule
            vc.delegate = self
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
    
    @objc func deleteDayBtn(sender: UIButton) {
        let alert = UIAlertController(title: "Удалить данные?", message: "Вы уверены, что хотите удалить этот день? Это действие невозможно отменить.", preferredStyle: .alert)
        
        let deleteAction = UIAlertAction(title: "Удалить", style: .destructive) { _ in
            self.deleteDay(dayID: sender.tag)
        }
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel) { _ in
            self.dismiss(animated: true)
        }
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
        
    }
    
    @objc func settings(sender: UIButton) {
        selectModule = course.courseDays[selectDay].modules[sender.tag]
        performSegue(withIdentifier: "goToModuleSettings", sender: self)
    }

}
extension AddModuleCoursesViewController: ChangeInfoModule {
    
    func changeInfoModuleDismiss(module: Modules, moduleID: Int) {
        for x in 0...course.courseDays[selectDay].modules.count - 1 {
            if course.courseDays[selectDay].modules[x].id == moduleID {
                course.courseDays[selectDay].modules[x] = module
                modulesCollectionView.reloadData()
            }
        }
    }
    
    func deleteModuleDismiss(moduleID: Int) {
        for x in 0...course.courseDays[selectDay].modules.count - 1 {
            if course.courseDays[selectDay].modules[x].id == moduleID {
                course.courseDays[selectDay].modules.remove(at: x)
                modulesCollectionView.reloadData()
            }
        }
    }
    
}
