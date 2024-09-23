//
//  Privacy.swift
//  Courses
//
//  Created by Руслан on 23.09.2024.
//

import Foundation
import UIKit
import Photos

class Privacy {
    
    func checkPhotoLibraryAuthorization() -> Bool {
        let photoLibraryAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        
        switch photoLibraryAuthorizationStatus {
        case .authorized:
            return true
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { status in
                DispatchQueue.main.async {
                    let _ = self.checkPhotoLibraryAuthorization()
                }
            }
        case .denied, .restricted:
            showAccessDeniedAlert()
        default:
            break
        }
        return false
    }
    
    func showAccessDeniedAlert() {
        let alert = UIAlertController(title: "Доступ к фотогалерее запрещен",
                                      message: "Пожалуйста, разрешите приложению доступ к фотогалерее в настройках.",
                                      preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: "Настройки", style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        alert.addAction(settingsAction)
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
    
        guard let rootViewController = UIApplication.shared.windows.first?.rootViewController else { return }
        rootViewController.present(alert, animated: true, completion: nil)
    }
}
