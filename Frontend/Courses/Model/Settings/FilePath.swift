//
//  FilePath.swift
//  Courses
//
//  Created by Руслан on 20.08.2024.
//

import Foundation
import Alamofire
import UIKit

class FilePath {
    
    func downloadFileWithURL(url: URL) async throws -> NSAttributedString {
        return try await withUnsafeThrowingContinuation { continuation in
            AF.download(url).responseData { response in
                switch response.result {
                case .success(let data):
                    guard let str = self.deserializeAttributedString(from: data) else {return}
                    continuation.resume(returning: str)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func deleteAlamofireFiles() {
        let fileManager = FileManager.default
        let tempDirectory = fileManager.temporaryDirectory
        let files = try! fileManager.contentsOfDirectory(at: tempDirectory, includingPropertiesForKeys: nil)
        for file in files where file.lastPathComponent.hasPrefix("Alamofire") {
            try! fileManager.removeItem(at: file)
        }
    }
    
    // Расспаковать файл
    func deserializeAttributedString(from data: Data) -> NSAttributedString? {
        do {
            if let attributedString = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? NSAttributedString {
                return getImagesFromAttributedString(attributedString)
            } else {
                print("Ошибка: не удалось преобразовать данные в NSAttributedString")
                return nil
            }
        } catch {
            print("Ошибка десериализации: \(error)")
            return nil
        }
    }
    
    // Запаковать файл
    func serializeAttributedStringToFile(_ attributedString: NSAttributedString) -> URL? {
        let fileManager = FileManager.default
        let tempDirectory = fileManager.temporaryDirectory
        let fileURL = tempDirectory.appendingPathComponent("attributedStringData").appendingPathExtension("data")
        
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: attributedString, requiringSecureCoding: false)
            try data.write(to: fileURL)
            return fileURL
        } catch {
            print("Error serializing attributed string to file: \(error)")
            return nil
        }
    }
    
    func getImagesFromAttributedString(_ attributedString: NSAttributedString) -> NSAttributedString {
      let mutableAttributedString = NSMutableAttributedString(attributedString: attributedString)

      mutableAttributedString.enumerateAttributes(in: NSRange(location: 0, length: attributedString.length), options: .longestEffectiveRangeNotRequired) { (attributes, range, _) in
          
        if let attachment = attributes[NSAttributedString.Key.attachment] as? NSTextAttachment,
          let image = attachment.image {
          let targetSize = resizeImageAboutTextView(image: image)
          attachment.bounds = CGRect(origin: .zero, size: targetSize)

          mutableAttributedString.replaceCharacters(in: range, with: NSAttributedString(attachment: attachment))
        }
      }
        
      return mutableAttributedString
    }

    
    private func resizeImageAboutTextView(image: UIImage) -> CGSize {
        let targetWidth = UIScreen.main.bounds.width - 30
        let aspectRatio = image.size.height / image.size.width
        let targetSize = CGSize(width: targetWidth, height: targetWidth * aspectRatio)
        return targetSize
    }




}
