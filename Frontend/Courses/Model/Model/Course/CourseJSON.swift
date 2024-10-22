//
//  CourseJSON.swift
//  Courses
//
//  Created by Руслан on 23.09.2024.
//

import Foundation
import SwiftyJSON

class CourseJSON {
    
    // MARK: - Days JSON
    func daysInCourse(value: Data) async throws -> Course {
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
                    let index = json["days"][x]["modules"][y]["order"].intValue
                    modules.append(Modules(text: URL(string: text), name: title, minutes: min, imageURL: URL(string: image), description: desc, id: id, position: index))
                }
            }
            course.courseDays.append(CourseDays(dayID: idDay, type: .noneSee, modules: modules))
            modules.removeAll()
        }
        course = RealmValue().addCompletedDays(course: course)
        return course
    }
    
    
    // MARK: - All Courses JSON
    func allCourses(value: Data) -> [Course] {
        let json = JSON(value)
        var courses = [Course]()

        let results = json["results"].arrayValue
        guard results.isEmpty == false else {return []}

        for x in 0...results.count - 1 {
            let daysCount = json["results"][x]["count_days"].intValue
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
            let isBought = json["results"][x]["bought"].boolValue
            let progressInDays = UD().getDaysCompletedInCourse(courseID: id)
            courses.append(Course(daysCount: daysCount, nameCourse: title, nameAuthor: "\(authorName) \(authorSurname)", idAuthor: authorID, price: price, imageURL: URL(string: image), rating: rating, id: id, description: description, dataCreated: dataCreated,progressInDays: progressInDays, countBuyer: countBuyer, isBought: isBought))
        }
        return courses
    }
    
    // MARK: - All Courses By another user
    func allCoursesByUser(value: Data) -> [Course] {
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
            let countBuyer = json[x]["bought_count"].intValue
            let rating = json[x]["rating"].floatValue
            let isBought = json[x]["bought"].boolValue
            let isDraft = json[x]["is_draft"].boolValue
            let progressInDays = UD().getDaysCompletedInCourse(courseID: id)
            courses.append(Course(daysCount: daysCount, nameCourse: title, nameAuthor: "\(authorName) \(authorSurname)", idAuthor: authorID, price: price, imageURL: URL(string: image), rating: rating, id: id, description: description, dataCreated: dataCreated, progressInDays: progressInDays, countBuyer: countBuyer, isBought: isBought, isDraft: isDraft))
        }
        return courses
    }
    
    // MARK: - One Course
    func course(value: Data) -> Course {
        let json = JSON(value)
        let daysCount = json["count_days"].intValue
        let title = json["title"].stringValue
        let price = json["price"].intValue
        let id = json["id"].intValue
        let image = json["image"].stringValue
        let description = json["desc"].stringValue
        let dataCreated = json["created_at"].stringValue
        let authorName = json["author"]["first_name"].stringValue
        let authorSurname = json["author"]["last_name"].stringValue
        let authorID = json["author"]["id"].intValue
        let rating = json["rating"].floatValue
        let myRating = json["my_rating"]["rating"].intValue
        let category = json["category"].intValue
        let boughtCount = json["bought_count"].intValue
        let isBought = json["bought"].boolValue
        let course = Course(daysCount: daysCount, nameCourse: title, nameAuthor: "\(authorName) \(authorSurname)",idAuthor: authorID, price: price, categoryID: category, imageURL: URL(string: image),rating: rating, myRating: myRating, id: id, description: description, dataCreated: dataCreated, countBuyer: boughtCount, isBought: isBought)
        return course
    }
}
