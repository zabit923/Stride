//
//  Course.swift
//  Course
//
//  Created by Руслан on 02.08.2024.
//

import Foundation
import Alamofire
import SwiftyJSON
import UIKit

// MARK: - Struct
struct Modules {
    var text: URL?
    var name: String
    var minutes: Int
    var imageURL: URL?
    var description: String?
    var id: Int
    var isRead: Bool = false
    var position: Int = 0
}


struct CourseDays {
    var dayID: Int
    var type: TypeDays = .noneSee
    var modules = [Modules]()
    
    init(dayID: Int, type: TypeDays, modules: [Modules] = [Modules]()) {
        self.dayID = dayID
        self.type = type
        self.modules = modules.sorted(by: { $0.id < $1.id })
    }
}

// MARK: - Class
class Course {
    var daysCount: Int
    var nameCourse: String
    var nameAuthor: String
    var idAuthor: Int
    var price: Int
    var categoryID: Int = 0
    var imageURL: URL?
    var rating: Float
    var myRating: Int
    var progressInDays: Int = 0
    var id: Int
    var description: String
    var dataCreated: String
    var countBuyer: Int = 0
    var isBought: Bool = false
    var courseDays = [CourseDays]()
    var isDraft: Bool

    init(daysCount: Int = 0, nameCourse: String = "", nameAuthor: String = "", idAuthor: Int = 0, price: Int = 0, categoryID: Int = 0, imageURL: URL? = nil, rating: Float = 0.0, myRating:Int = 0, id: Int = 0, description: String = "", dataCreated: String = "", progressInDays: Int = 0, countBuyer: Int = 0, isBought: Bool = false, isDraft: Bool = true) {
        self.daysCount = daysCount
        self.nameCourse = nameCourse
        self.nameAuthor = nameAuthor
        self.price = price
        self.categoryID = categoryID
        self.imageURL = imageURL
        self.rating = Comments().roundRating(rating: rating)
        self.myRating = myRating
        self.id = id
        self.description = description
        self.dataCreated = dataCreated
        self.idAuthor = idAuthor
        self.progressInDays = progressInDays
        self.countBuyer = countBuyer
        self.isBought = isBought
        self.isDraft = isDraft
    }
    
    private var mananger = CourseMananger()
    private var json = CourseJSON()

    // MARK: - Получить дни и модули

    func getDaysInCourse(id: Int) async throws -> Course {
        let value = try await mananger.getDaysValue(id: id)
        let course = try await json.daysInCourse(value: value)
        return course
    }

    // MARK: - Получить курсы

    func getAllCourses() async throws -> [Course] {
        let value = try await mananger.getAllCourses()
        let courses = json.allCourses(value: value)
        return courses
    }

    func getCoursesByID(id: Int) async throws -> Course {
        let value = try await mananger.getCoursesByID(id: id)
        let course = json.course(value: value)
        return course
    }

    func getCoursesByUserID(id: Int) async throws -> [Course] {
        let value = try await mananger.getCoursesByUserID(id: id)
        let courses = json.allCoursesByUser(value: value)
        return courses
    }

    func getCoursesByCelebrity() async throws -> [Course] {
        let value = try await mananger.getCoursesByCelebrity()
        let courses = json.allCoursesByUser(value: value)
        return courses
    }

    func getRecomendedCourses() async throws -> [Course] {
        let value = try await mananger.getRecomendedCourses()
        let courses = json.allCoursesByUser(value: value)
        return courses
    }


    // MARK: - Получить мои курсы

    func getBoughtCourses() async throws -> [Course] {
        let value = try await mananger.getBoughtCourses()
        let courses = json.allCoursesByUser(value: value)
        return courses
    }

    func getMyCreateCourses() async throws -> [Course] {
        let value = try await mananger.getMyCreateCourses()
        let courses = json.allCoursesByUser(value: value)
        return courses
    }

    // MARK: - Изменить

    func changeModuleInfo(info: Modules) async throws {
        let url = Constants.url + "api/v1/module/update/\(info.id)/"
        let headers: HTTPHeaders = ["Authorization": "Bearer \(User.info.token)"]
        let response =  AF.upload(multipartFormData: { multipartFormData in
            if let imageURL = info.imageURL, "\(imageURL)".starts(with: "file") {
                ImageResize.compressImageFromFileURL(fileURL: imageURL, maxSizeInMB: 0.1) { imageURL in
                    multipartFormData.append(imageURL!, withName: "image")
                }
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
            // Image
            if "\(info.imageURL!)".starts(with: "file") {
                ImageResize.compressImageFromFileURL(fileURL: info.imageURL!, maxSizeInMB: 0.1) { compressedURL in
                    if let url = compressedURL {
                        multipartFormData.append(url, withName: "image")
                    }
                }
            }
            // Черновик
            if method == .post {
                multipartFormData.append(Data("\(info.isDraft)".utf8), withName: "is_draft")
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

    func addModulesInCourse(dayID: Int, position: Int) async throws -> Int {
        let url = Constants.url + "api/v1/module/create/\(dayID)/"
        let headers: HTTPHeaders = ["Authorization": "Bearer \(User.info.token)"]
        let parameters = [
            "index": position
        ]
        let response = AF.request(url, method: .post, parameters: parameters, headers: headers).serializingData()
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
        let value = try await mananger.searchCourses(text: text)
        let courses = json.allCourses(value: value)
        return courses
    }

}
