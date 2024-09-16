//
//  ModulesCourseViewController.swift
//  Courses
//
//  Created by Руслан on 13.07.2024.
//

import UIKit
import Lottie

class ModulesCourseViewController: UIViewController {


    @IBOutlet weak var infoBtn: UIButton!
    @IBOutlet weak var loading: LottieAnimationView!
    @IBOutlet weak var nameCourse: UILabel!
    @IBOutlet weak var heightViewDays: NSLayoutConstraint!
    @IBOutlet weak var viewDays: UIView!
    @IBOutlet weak var daysCollectionView: UICollectionView!
    @IBOutlet weak var modulesCollectionView: UICollectionView!

    private let layout = PageModuleLayout()
    private var scaleView = false
    private var course = Course()
    private var selectDay: Int = 0
    private var selectModule = Modules(name: "", minutes: 0, id: 0)
    var idCourse = 0


    override func viewDidLoad() {
        super.viewDidLoad()
        loadingSettings()
        collectionSettings()
        getCourseInfo()
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

    private func loadingSettings() {
        loading.loopMode = .loop
        loading.contentMode = .scaleToFill
        loading.isHidden = false
    }

    private func loadingStop() {
        loading.stop()
        loading.isHidden = true
        infoBtn.isHidden = false
    }

    private func getCourseInfo() {
        Task {
            loading.play()
            do {
                course = try await Courses().getDaysInCourse(id: idCourse)
                if course.courseDays.isEmpty == false {
                    course.courseDays[0].type = .current
                }
                loadingStop()
                nameCourse.text = course.nameCourse
                daysCollectionView.reloadData()
                modulesCollectionView.reloadData()
            }catch {
                loadingStop()
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

    @IBAction func back(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func goToInfo(_ sender: UIButton) {
        performSegue(withIdentifier: "goToInfo", sender: self)
    }

}
extension ModulesCourseViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == daysCollectionView {
            return course.courseDays.count
        }else {
            if course.courseDays.isEmpty == false {
                return course.courseDays[selectDay].modules.count
            }else {
                return 0
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Day
        if collectionView == daysCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "day", for: indexPath) as! DaysCourseCollectionViewCell

            cell.lbl.text = "\(indexPath.row + 1)"

            switch course.courseDays[indexPath.row].type {
            case .current:
                cell.current()
            case .before:
                cell.before()
            case .noneSee:
                cell.noneCheck()
            }

            return cell
        }else {
            // Modules
            var cell = collectionView.dequeueReusableCell(withReuseIdentifier: "module2", for: indexPath) as! ModuleCourseCollectionViewCell

            guard course.courseDays.isEmpty == false else { return cell }

            if let image = course.courseDays[selectDay].modules[indexPath.row].imageURL {
                cell = collectionView.dequeueReusableCell(withReuseIdentifier: "module", for: indexPath) as! ModuleCourseCollectionViewCell
                cell.im.sd_setImage(with: image)
            }
            cell.name.text = course.courseDays[selectDay].modules[indexPath.row].name
            cell.time.text = "\(course.courseDays[selectDay].modules[indexPath.row].minutes) минут(ы/а)"
            cell.descrLbl.text = course.courseDays[selectDay].modules[indexPath.row].description

            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == daysCollectionView {
            course = RealmValue().addCompletedDays(course: course)
            course.courseDays[indexPath.row].type = .current
            selectDay = indexPath.row
            modulesCollectionView.reloadData()
            daysCollectionView.reloadData()
        }else {
            let module = course.courseDays[selectDay].modules[indexPath.row]
            RealmValue().addCompletedModule(course: course, module: module)
            selectModule = module
            performSegue(withIdentifier: "goToText", sender: self)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "goToText" {
            let vc = segue.destination as! CourseTextViewController
            vc.module = selectModule
        }else if segue.identifier == "goToInfo" {
            let vc = segue.destination as! InfoCoursesViewController
            vc.buy = false
            vc.course.id = idCourse
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

}
