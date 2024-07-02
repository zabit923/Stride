//
//  CatalogCollectionViewCell.swift
//  Courses
//
//  Created by Ибрагимов Эльдар on 01.07.2024.
//

import UIKit

class CoursesCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var nameAuthor: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var rating: UILabel!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var nameCourse: UILabel!
    @IBOutlet weak var progressInPercents: UILabel!
    @IBOutlet weak var progressInDays: UILabel!
    @IBOutlet weak var daysCount: UILabel!
    @IBOutlet weak var progressVIew: UIProgressView!
}
