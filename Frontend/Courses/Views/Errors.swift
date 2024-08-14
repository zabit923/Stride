//
//  Errors.swift
//  Courses
//
//  Created by Руслан on 23.06.2024.
//

import Foundation
import UIKit

class ErrorsView {
    
    func create(descriptionText:String, mainText:String, _ hiddenView:UIView, _ description: UILabel, _ main: UILabel) {
        hiddenView.isHidden = false
        description.text = descriptionText
        main.text = mainText
//        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//            self.delete(hiddenView)
//        }
    }
    
    func delete(_ hiddenView:UIView) {
        hiddenView.isHidden = true
    }
}
