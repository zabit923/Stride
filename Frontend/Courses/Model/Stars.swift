//
//  Stars.swift
//  Courses
//
//  Created by Ибрагимов Эльдар on 30.08.2024.
//

import Foundation
import UIKit

class Stars {
    func starsCount(firstButton: UIButton, secondButton: UIButton, thirdButton: UIButton, fourthButton: UIButton, fifthButton: UIButton, selectButton: SelectBtn) {
        firstButton.setImage(UIImage(named: "emptyStar"), for: .normal)
        secondButton.setImage(UIImage(named: "emptyStar"), for: .normal)
        thirdButton.setImage(UIImage(named: "emptyStar"), for: .normal)
        fourthButton.setImage(UIImage(named: "emptyStar"), for: .normal)
        fifthButton.setImage(UIImage(named: "emptyStar"), for: .normal)
        switch selectButton {
        case .firstButton:
            firstButton.setImage(UIImage(named: "bigStarFully"), for: .normal)
        case .secondButton:
            firstButton.setImage(UIImage(named: "bigStarFully"), for: .normal)
            secondButton.setImage(UIImage(named: "bigStarFully"), for: .normal)
        case .thirdButton:
            firstButton.setImage(UIImage(named: "bigStarFully"), for: .normal)
            secondButton.setImage(UIImage(named: "bigStarFully"), for: .normal)
            thirdButton.setImage(UIImage(named: "bigStarFully"), for: .normal)
        case .fourtFutton:
            firstButton.setImage(UIImage(named: "bigStarFully"), for: .normal)
            secondButton.setImage(UIImage(named: "bigStarFully"), for: .normal)
            thirdButton.setImage(UIImage(named: "bigStarFully"), for: .normal)
            fourthButton.setImage(UIImage(named: "bigStarFully"), for: .normal)
        case .fifthButton:
            firstButton.setImage(UIImage(named: "bigStarFully"), for: .normal)
            secondButton.setImage(UIImage(named: "bigStarFully"), for: .normal)
            thirdButton.setImage(UIImage(named: "bigStarFully"), for: .normal)
            fourthButton.setImage(UIImage(named: "bigStarFully"), for: .normal)
            fifthButton.setImage(UIImage(named: "bigStarFully"), for: .normal)
        }
    }
}
