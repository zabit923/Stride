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

    // MARK: - Получить дни и модули

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
                    modules.append(Modules(text: URL(string: text), name: title, minutes: min, imageURL: URL(string: image), description: desc, id: id))
                }
            }
            course.courseDays.append(CourseDays(dayID: idDay, type: .noneSee, modules: modules))
            modules.removeAll()
        }

        course = RealmValue().addCompletedDays(course: course)
        return course
    }

    // MARK: - Получить курсы

    func getAllCourses() async throws -> [Course] {
        let url = Constants.url + "api/v1/courses/"
        let headers: HTTPHeaders = ["Authorization": "Bearer \(User.info.token)"]
        let value = try await AF.request(url, headers: headers).serializingData().value
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
            courses.append(Course(daysCount: daysCount, nameCourse: title, nameAuthor: "\(authorName) \(authorSurname)", idAuthor: authorID, price: price, imageURL: URL(string: image), rating: rating, id: id, description: description, dataCreated: dataCreated, countBuyer: countBuyer, isBought: isBought))
        }

        return courses
    }

    func getCoursesByID(id: Int) async throws -> Course {
        let url = Constants.url + "api/v1/courses/\(id)/"
        let headers: HTTPHeaders = ["Authorization": "Bearer \(User.info.token)"]
        let value = try await AF.request(url, headers: headers).serializingData().value
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

    func getCoursesByUserID(id: Int) async throws -> [Course] {
        let url = Constants.url + "api/v1/courses/\(id)/courses_by_id/"
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
            let countBuyer = json[x]["bought_count"].intValue
            let rating = json[x]["rating"].floatValue
            let isBought = json[x]["bought"].boolValue
            courses.append(Course(daysCount: daysCount, nameCourse: title, nameAuthor: "\(authorName) \(authorSurname)", idAuthor: authorID, price: price, imageURL: URL(string: image), rating: rating, id: id, description: description, dataCreated: dataCreated, countBuyer: countBuyer, isBought: isBought))
        }
        return courses
    }

    func getCoursesByCelebrity() async throws -> [Course] {
        let url = Constants.url + "api/v1/courses/celebrities_courses/"
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
            let countBuyer = json[x]["bought_count"].intValue
            let rating = json[x]["rating"].floatValue
            let isBought = json[x]["bought"].boolValue
            courses.append(Course(daysCount: daysCount, nameCourse: title, nameAuthor: "\(authorName) \(authorSurname)", idAuthor: authorID, price: price, imageURL: URL(string: image), rating: rating, id: id, description: description, dataCreated: dataCreated, countBuyer: countBuyer, isBought: isBought))
        }

        return courses
    }

    func getRecomendedCourses() async throws -> [Course] {
        let url = Constants.url + "api/v1/courses/recommended_courses/"
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
            let countBuyer = json[x]["bought_count"].intValue
            let rating = json[x]["rating"].floatValue
            let isBought = json[x]["bought"].boolValue
            courses.append(Course(daysCount: daysCount, nameCourse: title, nameAuthor: "\(authorName) \(authorSurname)", idAuthor: authorID, price: price, imageURL: URL(string: image), rating: rating, id: id, description: description, dataCreated: dataCreated, countBuyer: countBuyer,isBought: isBought))
        }

        return courses
    }


    // MARK: - Получить мои курсы

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
            let myRating = json[x]["my_rating"]["rating"].intValue
            let progressInDays = UD().getDaysCompletedInCourse(courseID: id)
            courses.append(Course(daysCount: daysCount, nameCourse: title, nameAuthor: "\(authorName) \(authorSurname)", idAuthor: authorID, price: price, imageURL: URL(string: image), rating: rating, myRating: myRating, id: id, description: description, dataCreated: dataCreated, progressInDays: progressInDays))
        }
        return courses
    }

    func getMyCreateCourses() async throws -> [Course] {
        let url = Constants.url + "api/v1/courses/my_courses/"
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
            courses.append(Course(daysCount: daysCount, nameCourse: title, nameAuthor: "\(authorName) \(authorSurname)", idAuthor: authorID, price: price, imageURL: URL(string: image),rating: rating, id: id, description: description, dataCreated: dataCreated))
        }

        return courses

    }

    // MARK: - Изменить

    func changeModuleInfo(info: Modules) async throws {
        let url = Constants.url + "api/v1/module/update/\(info.id)/"
        let headers: HTTPHeaders = ["Authorization": "Bearer \(User.info.token)"]
        let response =  AF.upload(multipartFormData: { multipartFormData in
            if let imageURL = info.imageURL, "\(imageURL)".starts(with: "file") {
                multipartFormData.append(imageURL, withName: "image")
            }
            multipartFormData.append(Data(info.name.utf8), withName: "title")
            multipartFormData.append(Data(info.description!.utf8), withName: "desc")
            multipartFormData.append(Data("\(info.minutes)".utf8), withName: "time_to_pass")
        }, to: url, method: .patch, headers: headers).serializingData()
        let value = try await response.value
        let code = await response.response.response?.statusCode
        let json = JSON(value)
        if code != 200 {
            if let dictionary = json.dictionary {
                let error = dictionary.first!.value[0].stringValue
                throw ErrorNetwork.runtimeError(error)
            }else {
                throw ErrorNetwork.runtimeError("Неизвестная ошибка")
            }
        }
    }


    // MARK: - Добавить

    func saveInfoCourse(info: Course, method: HTTPMethod = .post) async throws -> Int {
        var url = Constants.url + "api/v1/courses/"
        if method == .patch {
            url += "\(info.id)/"
        }
        let headers: HTTPHeaders = ["Authorization": "Bearer \(User.info.token)"]
        let response = AF.upload(multipartFormData: { multipartFormData in
            if "\(info.imageURL!)".starts(with: "file") {
                ImageResize.compressImageFromFileURL(fileURL: info.imageURL!, maxSizeInMB: 1.0) { compressedURL in
                    if let url = compressedURL {
                        multipartFormData.append(url, withName: "image")
                    }
                }
            }
            multipartFormData.append(Data(info.nameCourse.utf8), withName: "title")
            multipartFormData.append(Data("\(info.price)".utf8), withName: "price")
            multipartFormData.append(Data(info.description.utf8), withName: "desc")
            multipartFormData.append(Data("\(info.categoryID)".utf8), withName: "category")
        }, to: url, method: method, headers: headers).serializingData()
        let value = try await response.value
        let code = await response.response.response?.statusCode
        let json = JSON(value)
        if code != 200 && method == .patch {
            if let dictionary = json.dictionary {
                let error = dictionary.first!.value[0].stringValue
                throw ErrorNetwork.runtimeError(error)
            }else {
                throw ErrorNetwork.runtimeError("Неизвестная ошибка")
            }
        }

        if code != 201 && method == .post {
            if let dictionary = json.dictionary {
                let error = dictionary.first!.value[0].stringValue
                throw ErrorNetwork.runtimeError(error)
            }else {
                throw ErrorNetwork.runtimeError("Неизвестная ошибка")
            }
        }
        let idCourse = json["id"].intValue
        return idCourse
    }

    func addDaysInCourse(courseID: Int) async throws -> Int {
        let url = Constants.url + "api/v1/day/create/\(courseID)/"
        let headers: HTTPHeaders = ["Authorization": "Bearer \(User.info.token)"]
        let response = AF.request(url, method: .post, headers: headers).serializingData()
        let value = try await response.value
        let code = await response.response.response?.statusCode
        let json = JSON(value)
        if code != 201 {
            if let dictionary = json.dictionary {
                let error = dictionary.first!.value[0].stringValue
                throw ErrorNetwork.runtimeError(error)
            }else {
                throw ErrorNetwork.runtimeError("Неизвестная ошибка")
            }
        }
        let id = json["id"].intValue
        return id
    }

    func addModulesInCourse(dayID: Int) async throws -> Int {
        let url = Constants.url + "api/v1/module/create/\(dayID)/"
        let headers: HTTPHeaders = ["Authorization": "Bearer \(User.info.token)"]
        let response = AF.request(url, method: .post, headers: headers).serializingData()
        let value = try await response.value
        let code = await response.response.response?.statusCode
        let json = JSON(value)
        if code != 201 {
            if let dictionary = json.dictionary {
                let error = dictionary.first!.value[0].stringValue
                throw ErrorNetwork.runtimeError(error)
            }else {
                throw ErrorNetwork.runtimeError("Неизвестная ошибка")
            }
        }
        let id = json["id"].intValue
        return id
    }

    func addModulesData(text: NSAttributedString, moduleID: Int) async throws {
        let url = Constants.url + "api/v1/module/update/\(moduleID)/"
        let headers: HTTPHeaders = ["Authorization": "Bearer \(User.info.token)"]
        let file = FilePath().serializeAttributedStringToFile(text)!
        let tempFileURL = file.deletingPathExtension().appendingPathExtension("data")
        let response = AF.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(tempFileURL, withName: "data")
        }, to: url, method: .patch, headers: headers).serializingData()
        let value = try await response.value
        let code = await response.response.response?.statusCode
        let json = JSON(value)
        if code != 200 {
            if let dictionary = json.dictionary {
                let error = dictionary.first!.value[0].stringValue
                throw ErrorNetwork.runtimeError(error)
            }else {
                throw ErrorNetwork.runtimeError("Неизвестная ошибка")
            }
        }
    }

    // MARK: - Удалить

    func deleteModule(moduleID: Int) async throws {
        let url = Constants.url + "api/v1/module/delete/\(moduleID)/"
        let headers: HTTPHeaders = ["Authorization": "Bearer \(User.info.token)"]
        let response =  AF.request(url, method: .delete, headers: headers).serializingData()
        let value = try await response.value
        let code = await response.response.response?.statusCode
        let json = JSON(value)
        if code != 204 {
            if let dictionary = json.dictionary {
                let error = dictionary.first!.value[0].stringValue
                throw ErrorNetwork.runtimeError(error)
            }else {
                throw ErrorNetwork.runtimeError("Неизвестная ошибка")
            }
        }
    }

    func deleteDay(dayID: Int) async throws {
        let url = Constants.url + "api/v1/day/delete/\(dayID)/"
        let headers: HTTPHeaders = ["Authorization": "Bearer \(User.info.token)"]
        let response =  AF.request(url, method: .delete, headers: headers).serializingData()
        let value = try await response.value
        let code = await response.response.response?.statusCode
        let json = JSON(value)
//        if code != 204 {
//            let error = json.dictionary!.first!.value[0].stringValue
//            throw ErrorNetwork.runtimeError(error)
//        }
    }

    // MARK: - Купить курс

    func buyCourse(id: Int) async throws  {
        let url = Constants.url + "api/v1/courses/\(id)/buy_course/"
        let headers: HTTPHeaders = ["Authorization": "Bearer \(User.info.token)"]
        let response = AF.request(url, method: .post, headers: headers).serializingData()
        let value = try await response.value
        let code = await response.response.response?.statusCode
        let json = JSON(value)
        if code != 201 {
            if let dictionary = json.dictionary {
                let error = dictionary.first!.value[0].stringValue
                throw ErrorNetwork.runtimeError(error)
            }else {
                throw ErrorNetwork.runtimeError("Неизвестная ошибка")
            }
        }
    }

    // MARK: - Поиск
    func searchCourses(text: String) async throws -> [Course] {
        let url = Constants.url + "api/v1/autocomplete/courses/"
        let parameters = [
            "title": text
        ]
        let headers: HTTPHeaders = ["Authorization": "Bearer \(User.info.token)"]
        let value = try await AF.request(url, parameters: parameters, headers: headers).serializingData().value
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
            courses.append(Course(daysCount: daysCount, nameCourse: title, nameAuthor: "\(authorName) \(authorSurname)", idAuthor: authorID, price: price, imageURL: URL(string: image), rating: rating, id: id, description: description, dataCreated: dataCreated, countBuyer: countBuyer))
        }

        return courses
    }

}
