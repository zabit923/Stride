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
            compression -= 0.1
            imageData = image.jpegData(compressionQuality: compression)
        }
        
        let url = ImageResize().imageToURL(image: UIImage(data:imageData!)!, fileName: "compressedImage")
        return url
    }

    
    static func resizeAndCompressImage(image: UIImage, maxSizeKB: Int) -> UIImage {
        
        
        guard let imageData = image.jpegData(compressionQuality: 1.0), imageData.count > maxSizeKB else {
            return image
        }
        
        var newImage: UIImage?
        var scaleFactor: CGFloat = 1.0
        
        
        while scaleFactor > 0.1 && (newImage == nil || newImage!.jpegData(compressionQuality: 1.0)!.count > maxSizeKB) {
            scaleFactor -= 0.1
            let newSize = CGSize(width: image.size.width * scaleFactor, height: image.size.height * scaleFactor)
            print(newSize)
            newImage = image.scaleImage(toSize: newSize)
        }
        
        
        return newImage!
    }


    func imageToURL(image: UIImage, fileName: String) -> URL {
        let tempURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("\(fileName).jpg")

        try? image.jpegData(compressionQuality: 0.1)?.write(to: tempURL, options: .atomic)
        return tempURL
    }
    
    func deleteTempImage(atURL: URL) {
        try? FileManager.default.removeItem(at: atURL)
    }

}
