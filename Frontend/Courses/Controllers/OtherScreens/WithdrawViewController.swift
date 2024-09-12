//
//  WithdrawViewController.swift
//  Courses
//
//  Created by Ибрагимов Эльдар on 12.09.2024.
//

import UIKit
import SDWebImage

class WithdrawViewController: UIViewController {

    @IBOutlet weak var moneyCount: UILabel!
    @IBOutlet weak var withdrawCollectionView: UICollectionView!
    @IBOutlet weak var withdrawTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        design()
        withdrawCollectionView.delegate = self
        withdrawCollectionView.dataSource = self
    }
    
    private func design() {
        let font = UIFont(name: "Commissioner-SemiBold", size: 12)
        withdrawTextField.attributedPlaceholder = NSAttributedString(string: "от 100₽ до 50000₽", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray, NSAttributedString.Key.font: font!])
    }

}

extension WithdrawViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = withdrawCollectionView.dequeueReusableCell(withReuseIdentifier: "withdraw", for: indexPath) as! WithdrawCollectionViewCell
        cell.commission.text = "Комиссия: 0%"
        cell.number.text = "*** 9952"
        cell.image = UIImageView(image: UIImage(named: "next2"))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 128, height: 100)
    }
    
    
}
