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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        bannersCollectionView.delegate = self
        bannersCollectionView.dataSource = self
    }
    


}
extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == bannersCollectionView {
            return 10000
        }else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == bannersCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "banner", for: indexPath) as! BannerCollectionViewCell
            //banners[indexPath.row % banners.count]
            return cell
        }else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "banner", for: indexPath) as! BannerCollectionViewCell
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = UIScreen.main.bounds.width
        
        if collectionView == bannersCollectionView {
            let resultWidth = screenWidth - 60
            return CGSize(width: resultWidth, height: 180)
        }else {
            let resultWidth = screenWidth - 60
            return CGSize(width: resultWidth, height: 180)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, targetContentOffsetForProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        let bannersWidth = UIScreen.main.bounds.width - 60
        let indexPath = round(collectionView.contentOffset.x / bannersWidth)
        let result = indexPath * 12
        print("bannersWidth: \(bannersWidth)")
        print("indexPath: \(indexPath)")
        print("result: \(result)")
        let target = CGPoint(x: indexPath * bannersWidth + result, y: 0)
        print("targetContentOffset: \(target)")
        return target
    }
    
    
    
    
}
