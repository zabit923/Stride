//
//  ModulesCourseViewController.swift
//  Courses
//
//  Created by Руслан on 13.07.2024.
//

import UIKit

class ModulesCourseViewController: UIViewController {
    
    @IBOutlet weak var daysCollectionView: UICollectionView!
    @IBOutlet weak var modulesCollectionView: UICollectionView!
    
    private let layout = PageModuleLayout()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionSettings()
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
    
    @IBAction func back(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
extension ModulesCourseViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == daysCollectionView {
            return 30
        }else {
            return 10
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == daysCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "day", for: indexPath) as! DaysCourseCollectionViewCell
            cell.before()
            return cell
        }else {
            var cell = collectionView.dequeueReusableCell(withReuseIdentifier: "module", for: indexPath) as! ModuleCourseCollectionViewCell
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "module2", for: indexPath) as! ModuleCourseCollectionViewCell
            return cell
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
