//
//  CategoriesCollectionViewCell.swift
//  Courses
//
//  Created by Ибрагимов Эльдар on 01.07.2024.
//

import UIKit

class CategoriesCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var selectCategory: Border!
    @IBOutlet weak var nameCategory: UILabel!
    @IBOutlet weak var image: UIImageView!
    
    func selectCategory(select: Int?, indexPath: Int) {
        if select == nil {
            selectCategory.layer.borderColor = UIColor.clear.cgColor
        }else if select == indexPath {
            selectCategory.layer.borderColor = UIColor.blueMain.cgColor
        }else {
            selectCategory.layer.borderColor = UIColor.clear.cgColor
        }
    }
}
