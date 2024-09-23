//
//  CropImage.swift
//  Courses
//
//  Created by Руслан on 19.09.2024.
//

import UIKit
import CropViewController

class CropImage: NSObject {
    var vc: UIViewController
    var vcCrop = CropViewController(image: UIImage())
    
    func showModuleImageCourse(with image: UIImage) {
        vcCrop = CropViewController(croppingStyle: .default, image: image)
        vcCrop.customAspectRatio = CGSize(width: 16, height: 6)
        vcCrop.aspectRatioLockEnabled = true
        vcCrop.aspectRatioPickerButtonHidden = true
        vcCrop.toolbarPosition = .bottom
        vcCrop.doneButtonTitle = "Продолжить"
        vcCrop.doneButtonColor = UIColor.blueMain
        vcCrop.cancelButtonTitle = "Отменить"
        vcCrop.cancelButtonColor = .errorRed
        vc.present(vcCrop, animated: true)
    }
    
    func showMainImageCourse(with image: UIImage) {
        vcCrop = CropViewController(croppingStyle: .default, image: image)
        vcCrop.aspectRatioPreset = .preset4x3
        vcCrop.aspectRatioLockEnabled = true
        vcCrop.aspectRatioPickerButtonHidden = true
        vcCrop.toolbarPosition = .bottom
        vcCrop.doneButtonTitle = "Продолжить"
        vcCrop.doneButtonColor = UIColor.blueMain
        vcCrop.cancelButtonTitle = "Отменить"
        vcCrop.cancelButtonColor = .errorRed
        vc.present(vcCrop, animated: true)
    }
    
    func showAvatarCrop(with image: UIImage) {
        vcCrop = CropViewController(croppingStyle: .circular, image: image)
        vcCrop.aspectRatioPreset = .presetSquare
        vcCrop.aspectRatioLockEnabled = true
        vcCrop.toolbarPosition = .bottom
        vcCrop.doneButtonTitle = "Продолжить"
        vcCrop.doneButtonColor = UIColor.blueMain
        vcCrop.cancelButtonTitle = "Отменить"
        vcCrop.cancelButtonColor = .errorRed
        vc.present(vcCrop, animated: true)
    }
    
    init(vc: UIViewController) {
        self.vc = vc
    }
    
}
