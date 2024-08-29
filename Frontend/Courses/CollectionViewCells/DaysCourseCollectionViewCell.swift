//
//  DaysCourseCollectionViewCell.swift
//  Courses
//
//  Created by Руслан on 14.07.2024.
//

import UIKit

class DaysCourseCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var delete: UIButton!
    @IBOutlet weak var lbl: UILabel!
    
    func noneCheck() {
        self.layer.borderColor = UIColor.clear.cgColor
        self.backgroundColor = .clear
    }
    
    func current() {
        self.backgroundColor = .clear
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor.extraLightBlackMain.cgColor
    }
    
    func before() {
        self.layer.borderColor = UIColor.clear.cgColor
        self.backgroundColor = UIColor.extraLightBlackMain
    }
}
