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
        UIGraphicsBeginImageContext(size)
        self.draw(in: CGRect(origin: .zero, size: size))
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
    
    func getURLs() -> [URL] {
        // Используйте регулярное выражение для поиска URL
        let pattern = "(https?://[\\w\\.-]+(/[\\w\\.-]+)+)"
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count))
        
        // Извлечение URL из совпадений
        return matches.compactMap { match in
            let range = Range(match.range, in: text)!
            return URL(string: String(text[range]))
        }
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
    
    func strikeText() -> NSMutableAttributedString {
        let attributeString = NSMutableAttributedString(string: self)
        attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: NSMakeRange(0, attributeString.length))
        return attributeString
    }
}

extension NSAttributedString {
    
    func htmlString() -> String? {
        let htmlData = try? self.data(from: NSRange(location: 0, length: self.length), documentAttributes: [NSAttributedString.DocumentAttributeKey.documentType: NSAttributedString.DocumentType.html])
        return String(data: htmlData ?? Data(), encoding: .utf8)
    }
}
