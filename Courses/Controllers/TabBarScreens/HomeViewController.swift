//
//  HomeViewController.swift
//  Courses
//
//  Created by Руслан on 24.06.2024.
//

import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var bannersCollectionView: UICollectionView!
    @IBOutlet weak var imProfile: UIImageView!
    
    private var banners = [String]()
    private let layout = PageLayout()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        collectionViewSettings()
        getBanners()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let x = (layout.itemSize.width + layout.minimumInteritemSpacing) * 1000000
        bannersCollectionView.setContentOffset(CGPoint(x: x, y: 0), animated: false)
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
    }
    
    func getBanners() {
        banners.append("first")
        banners.append("second")
        bannersCollectionView.reloadData()
    }


}
extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == bannersCollectionView {
            return Int.max
        }else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == bannersCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "banner", for: indexPath) as! BannerCollectionViewCell
            cell.im.image = UIImage(named: banners[indexPath.row % banners.count]) 
            return cell
        }else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "banner", for: indexPath) as! BannerCollectionViewCell
            return cell
        }
    }
    
}
