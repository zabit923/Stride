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
                    continuation.resume(returning: self.deserializeAttributedString(from: data)!)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // Расспаковать файл
    func deserializeAttributedString(from data: Data) -> NSAttributedString? {
        do {
            if let attributedString = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? NSAttributedString {
                return attributedString
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
    
}
