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
    
    func selectCategory(selectCategoryID: Int?, categoryID: Int) {
        if selectCategoryID == nil {
            selectCategory.layer.borderColor = UIColor.clear.cgColor
        }else if selectCategoryID == categoryID {
            selectCategory.layer.borderColor = UIColor.blueMain.cgColor
        }else {
            selectCategory.layer.borderColor = UIColor.clear.cgColor
        }
    }
}
