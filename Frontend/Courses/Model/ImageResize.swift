//
//  ImageResize.swift
//  Courses
//
//  Created by Руслан on 11.09.2024.
//

import Foundation
import UIKit

class ImageResize {
    
    static func compressImageFromFileURL(fileURL: URL, maxSizeInMB: Double, completion: @escaping (URL?) -> Void) {
        do {
            let data = try Data(contentsOf: fileURL)
            guard let image = UIImage(data: data) else {
                completion(nil)
                return
            }
            
            let compressedData = compressImageToMaxSize(image: image, maxSizeInMB: maxSizeInMB)
            completion(compressedData)
        } catch {
            print("Ошибка при загрузке данных из файла: \(error)")
            completion(nil)
        }
    }

    static func compressImageToMaxSize(image: UIImage, maxSizeInMB: Double) -> URL? {
        let maxSizeInBytes = Int(maxSizeInMB * 1024 * 1024)
        var compression: CGFloat = 1.0
        var imageData = image.jpegData(compressionQuality: compression)

        while imageData?.count ?? 0 > maxSizeInBytes && compression > 0 {
            compression -= 0.1 // Уменьшаем качество на 10%
            imageData = image.jpegData(compressionQuality: compression)
        }
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let compressedImageURL = documentsDirectory.appendingPathComponent("compressedImage.jpg")
        
        do {
            try imageData?.write(to: compressedImageURL)
            return compressedImageURL
        } catch {
            print("Ошибка при сохранении сжатого изображения: \(error)")
            return nil
        }
    }



}
