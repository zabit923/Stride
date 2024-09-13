//
//  ImageGallery.swift
//  Courses
//
//  Created by Руслан on 26.06.2024.
//

import Foundation
import UIKit

class ImagePicker: NSObject, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    var imagePickerController: UIImagePickerController?
    var completion: ((UIImage) -> ())?

    func openGallery(in viewController: UIViewController, completion: ((UIImage) -> ())?) {
        self.completion = completion
        imagePickerController = UIImagePickerController()
        imagePickerController?.delegate = self
        viewController.present(imagePickerController!, animated: true)
    }



}
