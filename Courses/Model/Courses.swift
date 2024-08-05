//
//  Courses.swift
//  Courses
//
//  Created by Руслан on 02.08.2024.
//

import Foundation
import Alamofire
import SwiftyJSON

class Courses {
    
    func getAllCourses() async throws -> [Course] {
        let url = Constants.url + "/api/v1/courses/"
        let headers: HTTPHeaders = ["Authorization": "Bearer \(User.info.token)"]
        let value = try await AF.request(url, headers: headers).serializingData().value
        let json = JSON(value)
        var courses = [Course]()
        
        let results = json["results"].arrayValue
        for x in 0...results.count - 1 {
            let daysCount = json["results"][x]["days"].arrayValue.count
            let title = json["results"][x]["title"].stringValue
            let price = json["results"][x]["price"].intValue
            let id = json["results"][x]["id"].intValue
            let image = json["results"][x]["image"].stringValue
            let description = json["results"][x]["desc"].stringValue
            let dataCreated = json["results"][x]["created_at"].stringValue
            courses.append(Course(daysCount: daysCount, nameCourse: title, price: price, image: image, id: id, description: description, dataCreated: dataCreated))
        }
        
        return courses
    }
    
    func getCoursesByID(id: Int) async throws -> Course {
        let url = Constants.url + "/api/v1/courses/\(id)/"
        print(url)
        let headers: HTTPHeaders = ["Authorization": "Bearer \(User.info.token)"]
        let value = try await AF.request(url, headers: headers).serializingData().value
        let json = JSON(value)
        print(json)
        let daysCount = json["days"].arrayValue.count
        let title = json["title"].stringValue
        let price = json["price"].intValue
        let id = json["id"].intValue
        let image = json["image"].stringValue
        let description = json["desc"].stringValue
        let dataCreated = json["created_at"].stringValue
        let course = Course(daysCount: daysCount, nameCourse: title, price: price, image: image, id: id, description: description, dataCreated: dataCreated)
        return course
    }
}
