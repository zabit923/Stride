//
//  Courses.swift
//  Courses
//
//  Created by Руслан on 02.08.2024.
//

import Foundation
import Alamofire
import SwiftyJSON
import UIKit

class Courses {
    
    func getMyCreateCourses() async throws -> [Course] {
        let url = Constants.url + "api/v1/courses/my_courses/"
        let headers: HTTPHeaders = ["Authorization": "Bearer \(User.info.token)"]
        let value = try await AF.request(url, headers: headers).serializingData().value
        let json = JSON(value)
        var courses = [Course]()
        
        let results = json.arrayValue
        guard results.isEmpty == false else {return []}
        
        for x in 0...results.count - 1 {
            let daysCount = json[x]["days"].arrayValue.count
            let title = json[x]["title"].stringValue
            let price = json[x]["price"].intValue
            let id = json[x]["id"].intValue
            let image = json[x]["image"].stringValue
            let description = json[x]["desc"].stringValue
            let dataCreated = json[x]["created_at"].stringValue
            let authorName = json[x]["author"]["first_name"].stringValue
            let authorSurname = json[x]["author"]["last_name"].stringValue
            let authorID = json[x]["author"]["id"].intValue
            courses.append(Course(daysCount: daysCount, nameCourse: title, nameAuthor: "\(authorName) \(authorSurname)", idAuthor: authorID, price: price, imageURL: URL(string: image), id: id, description: description, dataCreated: dataCreated))
        }
        
        return courses

    }
    
    func getAllCourses() async throws -> [Course] {
        let url = Constants.url + "api/v1/courses/"
        let headers: HTTPHeaders = ["Authorization": "Bearer \(User.info.token)"]
        let value = try await AF.request(url, headers: headers).serializingData().value
        let json = JSON(value)
        var courses = [Course]()
        
        let results = json["results"].arrayValue
        guard results.isEmpty == false else {return []}
        
        for x in 0...results.count - 1 {
            let daysCount = json["results"][x]["days"].arrayValue.count
            let title = json["results"][x]["title"].stringValue
            let price = json["results"][x]["price"].intValue
            let id = json["results"][x]["id"].intValue
            let image = json["results"][x]["image"].stringValue
            let description = json["results"][x]["desc"].stringValue
            let dataCreated = json["results"][x]["created_at"].stringValue
            let authorName = json["results"][x]["author"]["first_name"].stringValue
            let authorSurname = json["results"][x]["author"]["last_name"].stringValue
            let authorID = json["results"][x]["author"]["id"].intValue
            let countBuyer = json["results"][x]["bought_count"].intValue
            let rating = json["results"][x]["rating"].floatValue
            courses.append(Course(daysCount: daysCount, nameCourse: title, nameAuthor: "\(authorName) \(authorSurname)", idAuthor: authorID, price: price, imageURL: URL(string: image), rating: rating, id: id, description: description, dataCreated: dataCreated, countBuyer: countBuyer))
        }
        
        return courses
    }
    
    func getDaysInCourse(id: Int) async throws -> Course {
        let url = Constants.url + "api/v1/courses/\(id)/"
        let headers: HTTPHeaders = ["Authorization": "Bearer \(User.info.token)"]
        let value = try await AF.request(url, headers: headers).serializingData().value
        let json = JSON(value)
        var course = Course()
        var modules = [Modules]()
        course.nameCourse = json["title"].stringValue
        course.id = json["id"].intValue
        let daysCount = json["days"].arrayValue.count
        guard daysCount > 0 else {throw ErrorNetwork.runtimeError("Пустой массив")}
        
        for x in 0...daysCount - 1 {
            let idDay = json["days"][x]["id"].intValue
            let modulesArray = json["days"][x]["modules"].arrayValue
            if modulesArray.isEmpty == false {
                for y in 0...modulesArray.count - 1 {
                    let id = json["days"][x]["modules"][y]["id"].intValue
                    let text = json["days"][x]["modules"][y]["data"].stringValue
                    let min = json["days"][x]["modules"][y]["time_to_pass"].intValue
                    let title = json["days"][x]["modules"][y]["title"].stringValue
                    let image = json["days"][x]["modules"][y]["image"].stringValue
                    let desc = json["days"][x]["modules"][y]["desc"].stringValue
                    modules.append(Modules(text: URL(string: text)!, name: title, minutes: min, imageURL: URL(string: image), description: desc, id: id))
                }
            }
            course.courseDays.append(CourseDays(dayID: idDay, type: .noneSee, modules: modules))
            modules.removeAll()
        }
        
        course = RealmValue().addCompletedDays(course: course)
        return course
    }
    
    
    func getCoursesByID(id: Int) async throws -> Course {
        let url = Constants.url + "api/v1/courses/\(id)/"
        let headers: HTTPHeaders = ["Authorization": "Bearer \(User.info.token)"]
        let value = try await AF.request(url, headers: headers).serializingData().value
        let json = JSON(value)
        let daysCount = json["days"].arrayValue.count
        let title = json["title"].stringValue
        let price = json["price"].intValue
        let id = json["id"].intValue
        let image = json["image"].stringValue
        let description = json["desc"].stringValue
        let dataCreated = json["created_at"].stringValue
        let authorName = json["author"]["first_name"].stringValue
        let authorSurname = json["author"]["last_name"].stringValue
        let authorID = json["author"]["id"].intValue
        let course = Course(daysCount: daysCount, nameCourse: title, nameAuthor: "\(authorName) \(authorSurname)",idAuthor: authorID, price: price, imageURL: URL(string: image), id: id, description: description, dataCreated: dataCreated)
        return course
    }
    
    func saveInfoCourse(info: Course, method: HTTPMethod = .post) async throws -> Int {
        var url = Constants.url + "api/v1/courses/"
        if method == .patch {
            url += "\(info.id)/"
        }
        let headers: HTTPHeaders = ["Authorization": "Bearer \(User.info.token)"]
        let value = try await AF.upload(multipartFormData: { multipartFormData in
            if "\(info.imageURL!)".starts(with: "file") {
                multipartFormData.append(info.imageURL!, withName: "image")
            }
            multipartFormData.append(Data(info.nameCourse.utf8), withName: "title")
            multipartFormData.append(Data("\(info.price)".utf8), withName: "price")
            multipartFormData.append(Data(info.description.utf8), withName: "desc")
        }, to: url, method: method, headers: headers).serializingData().value
        let json = JSON(value)
        let idCourse = json["id"].intValue
        return idCourse
    }
    
    func buyCourse(id: Int) async throws  {
        let url = Constants.url + "api/v1/courses/\(id)/buy_course/"
        let headers: HTTPHeaders = ["Authorization": "Bearer \(User.info.token)"]
        let data = AF.request(url, method: .post, headers: headers).serializingData()
        if await data.response.response?.statusCode != 201 {
            throw ErrorNetwork.runtimeError("Ошибка")
        }
    }
    
    func getBoughtCourses() async throws -> [Course] {
        let url = Constants.url + "api/v1/courses/my_bought_courses/"
        let headers: HTTPHeaders = ["Authorization": "Bearer \(User.info.token)"]
        let value = try await AF.request(url, headers: headers).serializingData().value
        let json = JSON(value)
        var courses = [Course]()
        
        let results = json.arrayValue
        guard results.isEmpty == false else {return []}
        
        for x in 0...results.count - 1 {
            let daysCount = json[x]["count_days"].intValue
            let title = json[x]["title"].stringValue
            let price = json[x]["price"].intValue
            let id = json[x]["id"].intValue
            let image = json[x]["image"].stringValue
            let description = json[x]["desc"].stringValue
            let dataCreated = json[x]["created_at"].stringValue
            let authorName = json[x]["author"]["first_name"].stringValue
            let authorSurname = json[x]["author"]["last_name"].stringValue
            let authorID = json[x]["author"]["id"].intValue
            let rating = json[x]["rating"].floatValue
            courses.append(Course(daysCount: daysCount, nameCourse: title, nameAuthor: "\(authorName) \(authorSurname)", idAuthor: authorID, price: price, imageURL: URL(string: image), rating: rating ,id: id, description: description, dataCreated: dataCreated))
        }
        return courses
    }
    
    
    func getCoursesByUserID(id: Int) async throws -> [Course] {
        let url = Constants.url + "api/v1/courses/\(id)/courses_by_id/"
        let headers: HTTPHeaders = ["Authorization": "Bearer \(User.info.token)"]
        let value = try await AF.request(url, headers: headers).serializingData().value
        let json = JSON(value)
        var courses = [Course]()
        
        let results = json.arrayValue
        guard results.isEmpty == false else {return []}
        
        for x in 0...results.count - 1 {
            let title = json[x]["title"].stringValue
            let id = json[x]["id"].intValue
            let image = json[x]["image"].stringValue
            courses.append(Course(nameCourse: title, imageURL: URL(string: image), id: id))
        }
        return courses
    }
    
    func addDaysInCourse(courseID: Int) async throws -> Int {
        let url = Constants.url + "/api/v1/day/create/\(courseID)/"
        let headers: HTTPHeaders = ["Authorization": "Bearer \(User.info.token)"]
        let value = try await AF.request(url, method: .post, headers: headers).serializingData().value
        let json = JSON(value)
        let id = json["id"].intValue
        return id
    }
    
    func addModulesInCourse(dayID: Int) async throws -> Int {
        let url = Constants.url + "/api/v1/module/create/\(dayID)/"
        let headers: HTTPHeaders = ["Authorization": "Bearer \(User.info.token)"]
        let value = try await AF.request(url, method: .post, headers: headers).serializingData().value
        let json = JSON(value)
        print(json)
        let id = json["id"].intValue
        return id
    }
    
    func addModulesData(file: URL, moduleID: Int) async throws {
        let url = Constants.url + "/api/v1/module/update/\(moduleID)/"
        let headers: HTTPHeaders = ["Authorization": "Bearer \(User.info.token)"]
        let tempFileURL = file.deletingPathExtension().appendingPathExtension("data")
        let value = try await AF.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(tempFileURL, withName: "data")
        }, to: url, method: .patch, headers: headers).serializingData().value
        let json = JSON(value)
    }
    
}
