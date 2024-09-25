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

extension NSAttributedString {
    func toDictionary() -> [String: Any] {
        let string = self.string
        var attributes = [String: Any]()
        self.enumerateAttributes(in: NSRange(location: 0, length: string.count), options: []) { (attrs, range, _) in
            for (key, value) in attrs {
                let keyString = (key as? NSAttributedString.Key)?.rawValue ?? ""
                if let value = value as? [String: Any] {
                    attributes[keyString] = value
                } else if let value = value as? Any {
                    attributes[keyString] = value
                }
            }
        }

        return ["string": string, "attributes": attributes]
    }
}



extension UIImage {

    func scaleImage(toSize size: CGSize) -> UIImage {
        let newImage: UIImage
        let aspectWidth = size.width / self.size.width
        let aspectHeight = size.height / self.size.height
        let aspectRatio = min(aspectWidth, aspectHeight)
        
        let newSize = CGSize(width: self.size.width * aspectRatio, height: self.size.height * aspectRatio)
        UIGraphicsBeginImageContext(newSize)
        self.draw(in: CGRect(origin: .zero, size: newSize))
        newImage = UIGraphicsGetImageFromCurrentImageContext() ?? self
        UIGraphicsEndImageContext()

        return newImage
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

