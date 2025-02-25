//
//  CoachCollectionViewCell.swift
//  Courses
//
//  Created by Руслан on 12.11.2024.
//

import UIKit

class CoachCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var starFivth: UIImageView!
    @IBOutlet weak var starFourth: UIImageView!
    @IBOutlet weak var starThird: UIImageView!
    @IBOutlet weak var starSecond: UIImageView!
    @IBOutlet weak var starFirst: UIImageView!
    @IBOutlet weak var rating: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var im: UIImageView!
    
    func starPosititon(rating: Float) {
        let fullStars = Int(rating)
        
        starFirst.image = fullStars >= 1 ? UIImage(named: "starRating") : UIImage(named: "starClear")
        starSecond.image = fullStars >= 2 ? UIImage(named: "starRating") : UIImage(named: "starClear")
        starThird.image = fullStars >= 3 ? UIImage(named: "starRating") : UIImage(named: "starClear")
        starFourth.image = fullStars >= 4 ? UIImage(named: "starRating") : UIImage(named: "starClear")
        starFivth.image = fullStars >= 5 ? UIImage(named: "starRating") : UIImage(named: "starClear")
        
        if rating - Float(fullStars) >= 0.5 {
            starFirst.image = fullStars + 1 >= 1 ? UIImage(named: "starRating") : UIImage(named: "starClear")
            starSecond.image = fullStars + 1 >= 2 ? UIImage(named: "starRating") : UIImage(named: "starClear")
            starThird.image = fullStars + 1 >= 3 ? UIImage(named: "starRating") : UIImage(named: "starClear")
            starFourth.image = fullStars + 1 >= 4 ? UIImage(named: "starRating") : UIImage(named: "starClear")
            starFivth.image = fullStars + 1 >= 5 ? UIImage(named: "starRating") : UIImage(named: "starClear")
        }
    }
    
    
}
