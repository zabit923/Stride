//
//  Extension.swift
//  Courses
//
//  Created by Руслан on 26.06.2024.
//

import UIKit

extension Data {
    func retrieveDataToString() -> NSAttributedString {
        let attributedString = (try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(self) as? NSAttributedString)!
        return attributedString
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
    
    // Undo Redo
    func replaceRange(_ range: NSRange, withAttributedText text: NSAttributedString) {
         let previousText = attributedText.attributedSubstring(from: range)
         let previousSelectedRange = selectedRange

         undoManager?.registerUndo(withTarget: self, handler: { target in
             target.replaceRange(NSMakeRange(range.location, text.length),
                                 withAttributedText: previousText)
         })

         textStorage.replaceCharacters(in: range, with: text)
         selectedRange = NSMakeRange(previousSelectedRange.location, text.length)
     }
}



extension String {
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return nil }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return nil
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
}

extension NSAttributedString {
    
    func htmlString() -> String? {
        let htmlData = try? self.data(from: NSRange(location: 0, length: self.length), documentAttributes: [NSAttributedString.DocumentAttributeKey.documentType: NSAttributedString.DocumentType.html])
        return String(data: htmlData ?? Data(), encoding: .utf8)
    }
}
