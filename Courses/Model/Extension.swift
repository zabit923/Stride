//
//  Extension.swift
//  Courses
//
//  Created by Руслан on 26.06.2024.
//

import UIKit

extension NSAttributedString {
    
    func attributedStringToData() -> Data? {
        guard let data = try? NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false) else {
            print("Ошибка сериализации NSAttributedString")
            return nil
        }
        return data
    }
}

extension Data {
    func retrieveDataToString() -> NSAttributedString {
        let attributedString = (try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(self) as? NSAttributedString)!
        return attributedString
    }
}


extension UIImage {
    
    func scaleImage(toSize size: CGSize) -> UIImage {
        var scaledImageSize = size
        let imageSize = self.size
        let widthRatio = size.width / imageSize.width
        let heightRatio = size.height / imageSize.height
        
        if widthRatio < heightRatio {
            scaledImageSize = CGSize(width: size.width, height: imageSize.height * widthRatio)
        } else {
            scaledImageSize = CGSize(width: imageSize.width * heightRatio, height: size.height)
        }
        
        UIGraphicsBeginImageContextWithOptions(scaledImageSize, false, 0.0)
        self.draw(in: CGRect(origin: .zero, size: scaledImageSize))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage ?? self
    }
    
    func withRoundedCorners(radius: CGFloat) -> UIImage {
        let rect = CGRect(origin: .zero, size: self.size)
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        UIBezierPath(roundedRect: rect, cornerRadius: radius).addClip()
        self.draw(in: rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
}

extension UITextView {
    func convertUITextRangeToNSRange(range: UITextRange) -> NSRange {
        let beginning = self.beginningOfDocument
        let location = self.offset(from: beginning, to: range.start)
        let length = self.offset(from: range.start, to: range.end)
        return NSRange(location: location, length: length)
    }
}
