//
//  BanksTableViewCell.swift
//  Courses
//
//  Created by Ибрагимов Эльдар on 16.09.2024.
//

import UIKit

class BanksTableViewCell: UITableViewCell {
    
    @IBOutlet weak var im: UIImageView!
    @IBOutlet weak var name: UILabel!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            contentView.backgroundColor = UIColor.lightBlackMain // Цвет при выборе
        } else {
            contentView.backgroundColor = UIColor.lightBlackMain // Цвет по умолчанию
        }
    }
}

