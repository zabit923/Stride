//
//  AddModuleCoursesViewController.swift
//  Courses
//
//  Created by Руслан on 14.07.2024.
//

import UIKit
import Lottie

class AddModuleCoursesViewController: UIViewController {

    @IBOutlet weak var loading: LottieAnimationView!
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
        loadingSettings()
        addCourseInfo()
    }

    private func addCourseInfo() {
        Task {
            do {
                course = try await Course().getDaysInCourse(id: idCourse)
                nameCourses.text = course.nameCourse
                loadingStop()
                daysCollectionView.reloadData()
                modulesCollectionView.reloadData()
            }catch {
                loadingStop()
            }
        }
    }

    private func collectionSettings() {
        daysCollectionView.delegate = self
        daysCollectionView.dataSource = self
        modulesCollectionView.delegate = self
        modulesCollectionView.dataSource = self
        addGestureRecognizeByCollectionView()

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
    
    private func addGestureRecognizeByCollectionView() {
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongGesture(_:)))
        modulesCollectionView.addGestureRecognizer(gesture)
    }

    @objc func handleLongGesture(_ gesture: UILongPressGestureRecognizer) {
        guard let collectionView = modulesCollectionView else { return }
        switch gesture.state {
        case .began:
            guard let indexPath = collectionView.indexPathForItem(at: gesture.location(in: collectionView)) else { return }
            
            collectionView.beginInteractiveMovementForItem(at: indexPath)
        case .changed:
            collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: collectionView))
        case .ended:
            collectionView.endInteractiveMovement()
        default:
            collectionView.cancelInteractiveMovement()
        }
    }
    
    private func addDay() {
        Task {
            do {
                let id = try await Course().addDaysInCourse(courseID: idCourse)
                course.courseDays.append(CourseDays(dayID: id, type: .noneSee))
                daysCollectionView.insertItems(at: [IndexPath(item: course.courseDays.count - 1, section: 0)])
            }catch ErrorNetwork.runtimeError(let error) {
                errorView.isHidden = false
                errorView.configure(title: "Ошибка", description: error)
                view.addSubview(errorView)
            }
        }
    }

    private func addModule(dayID: Int, position: Int) {
        Task {
            do {
                let id = try await Course().addModulesInCourse(dayID: dayID, position: position)
                course.courseDays[selectDay].modules.append(Modules(name: "", minutes: 0, id: id, position: position))
                modulesCollectionView.insertItems(at: [IndexPath(item: position, section: 0)])
            }catch ErrorNetwork.runtimeError(let error) {
                errorView.isHidden = false
                errorView.configure(title: "Ошибка", description: error)
                view.addSubview(errorView)
            }
        }
    }
    
    private func loadingSettings() {
        loading.loopMode = .loop
        loading.contentMode = .scaleToFill
        loading.play()
        loading.isHidden = false
    }

    private func loadingStop() {
        loading.stop()
        loading.isHidden = true
    }
    
    private func selectBack(deleteIndex: Int) {
        if selectDay == course.courseDays.count - 1 {
            selectDay -= 1
        }
    }
    
    private func changePositionModule(module: Modules) {
        Task {
            try await Course().changePositionModule(info: module)
        }
    }
    
    private func deleteDay(dayID: Int) {
        Task {
            do {
                try await Course().deleteDay(dayID: dayID)
                for x in 0...course.courseDays.count - 1 {
                    if course.courseDays[x].dayID == dayID {
                        selectBack(deleteIndex: x)
                        course.courseDays.remove(at: x)
                        daysCollectionView.reloadData()
                        modulesCollectionView.reloadData()
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
            // Add +
            if indexPath.row == course.courseDays.count {
                cell = collectionView.dequeueReusableCell(withReuseIdentifier: "addDayCell", for: indexPath) as! DaysCourseCollectionViewCell
                return cell
            }else {
                cell.lbl.text = "\(indexPath.row + 1)"
                cell.delete.isHidden = false
                cell.delete.tag = course.courseDays[indexPath.row].dayID
                cell.delete.addTarget(self, action: #selector(deleteDayBtn), for: .touchUpInside)
                if selectDay == indexPath.row {
                    cell.current()
                    cell.delete.isHidden = true
                }else {
                    cell.before()
                }
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
            if course.courseDays[selectDay].modules[indexPath.row].minutes == 0 {
                cell.time.isHidden = true
            }else {
                cell.time.isHidden = false
                cell.time.text = "\(course.courseDays[selectDay].modules[indexPath.row].minutes) минут(ы/а)"
            }
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
                addModule(dayID: course.courseDays[selectDay].dayID, position: indexPath.row)
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
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        if indexPath.row == course.courseDays[selectDay].modules.count {
            return false
        }else {
            return true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard destinationIndexPath.row != course.courseDays[selectDay].modules.count else {
            collectionView.moveItem(at: destinationIndexPath, to: sourceIndexPath)
            return
        }
        
        var module = course.courseDays[selectDay].modules[sourceIndexPath.row]
        module.position = destinationIndexPath.row + 1
        changePositionModule(module: module)
        
        let movedModule = course.courseDays[selectDay].modules.remove(at: sourceIndexPath.row)
        course.courseDays[selectDay].modules.insert(movedModule, at: destinationIndexPath.row)
        
        
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
                break
            }
        }
    }

}
