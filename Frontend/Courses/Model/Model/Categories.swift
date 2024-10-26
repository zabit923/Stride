//
//  Categories.swift
//  Courses
//
//  Created by Руслан on 18.08.2024.
//

import Foundation
import Alamofire
import SwiftyJSON

class Category {
    
    var nameCategory: String
    var imageURL: URL
    var id: Int
    
    init(nameCategory: String, imageURL: URL, id: Int) {
        self.nameCategory = nameCategory
        self.imageURL = imageURL
        self.id = id
    }

    static func getCategories() async throws -> [Category] {
        let url = Constants.url + "api/v1/categories/"
        let headers: HTTPHeaders = ["Authorization": "Bearer \(User.info.token)"]
        let value = try await AF.request(url, headers: headers).serializingData().value
        let json = JSON(value)
        var categories = [Category]()

        let results = json["results"].arrayValue
        guard results.isEmpty == false else {return []}

        for x in 0...results.count - 1 {
            let title = json["results"][x]["title"].stringValue
            let image = json["results"][x]["image"].stringValue
            let id = json["results"][x]["id"].intValue
            categories.append(Category(nameCategory: title, imageURL: URL(string: image)!, id: id))
        }
        return categories
    }

}
