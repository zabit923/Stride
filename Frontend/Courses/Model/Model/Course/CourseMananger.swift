//
//  CourseMananger.swift
//  Courses
//
//  Created by Руслан on 23.09.2024.
//

import Foundation
import Alamofire

class CourseMananger {
    
    func getDaysValue(id: Int) async throws -> Data {
        let url = Constants.url + "api/v1/courses/\(id)/"
        let headers: HTTPHeaders = ["Authorization": "Bearer \(User.info.token)"]
        let response = AF.request(url, headers: headers).serializingData()
        let value = try await response.value
        return value
    }
    
    func getAllCourses(page: String?) async throws -> Data {
        var url = Constants.url + "api/v1/courses/"
        
        if let page = page {
            url = page
        }
        
        let headers: HTTPHeaders = ["Authorization": "Bearer \(User.info.token)"]
        let value = try await AF.request(url, headers: headers).serializingData().value
        return value
    }
    
    func getCoursesByCategory(id: Int) async throws -> Data {
        var url = Constants.url + "api/v1/courses/?category=\(id)"
        
        let headers: HTTPHeaders = ["Authorization": "Bearer \(User.info.token)"]
        let value = try await AF.request(url, headers: headers).serializingData().value
        return value
    }
    
    
    func getCoursesByID(id: Int) async throws -> Data {
        let url = Constants.url + "api/v1/courses/\(id)/"
        let headers: HTTPHeaders = ["Authorization": "Bearer \(User.info.token)"]
        let value = try await AF.request(url, headers: headers).serializingData().value
        return value
    }
    
    func getCoursesByUserID(id: Int) async throws -> Data {
        let url = Constants.url + "api/v1/courses/\(id)/courses_by_id/"
        let headers: HTTPHeaders = ["Authorization": "Bearer \(User.info.token)"]
        let value = try await AF.request(url, headers: headers).serializingData().value
        return value
    }
    
    func getCoursesByCelebrity() async throws -> Data {
        let url = Constants.url + "api/v1/courses/celebrities_courses/"
        let headers: HTTPHeaders = ["Authorization": "Bearer \(User.info.token)"]
        let value = try await AF.request(url, headers: headers).serializingData().value
        return value
    }
    
    func getPopularCourses() async throws -> Data {
        let url = Constants.url + "api/v1/courses/popular_courses/"
        let headers: HTTPHeaders = ["Authorization": "Bearer \(User.info.token)"]
        let value = try await AF.request(url, headers: headers).serializingData().value
        return value
    }
    
    func getRecomendedCourses() async throws -> Data {
        let url = Constants.url + "api/v1/courses/recommended_courses/"
        let headers: HTTPHeaders = ["Authorization": "Bearer \(User.info.token)"]
        let value = try await AF.request(url, headers: headers).serializingData().value
        return value
    }
    
    func getBoughtCourses() async throws -> Data {
        let url = Constants.url + "api/v1/courses/my_bought_courses/"
        let headers: HTTPHeaders = ["Authorization": "Bearer \(User.info.token)"]
        let value = try await AF.request(url, headers: headers).serializingData().value
        return value
    }
    
    func getMyCreateCourses() async throws -> Data {
        let url = Constants.url + "api/v1/courses/my_courses/"
        let headers: HTTPHeaders = ["Authorization": "Bearer \(User.info.token)"]
        let value = try await AF.request(url, headers: headers).serializingData().value
        return value
    }
    
    func searchCourses(text: String, category: Category?) async throws -> Data {
        let url = Constants.url + "api/v1/autocomplete/courses/"
        var parameters: Parameters = [
            "title": text
        ]
        if let category = category {
            parameters["category"] = category.id
        }
        let headers: HTTPHeaders = ["Authorization": "Bearer \(User.info.token)"]
        let value = try await AF.request(url, parameters: parameters, headers: headers).serializingData().value
        return value
    }
    
}
