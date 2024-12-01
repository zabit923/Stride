//
//  Promocodes.swift
//  Courses
//
//  Created by Руслан on 25.11.2024.
//

import Foundation
import Alamofire
import SwiftyJSON

class Promocodes {
    
    var name: String
    var procent: Int
    var dateStart: String?
    var dateEnd: String?
    var buyers: Int
    var countCourses: Int
    var id: Int
    
    init(name: String, procent: Int, dateStart: String, dateEnd: String, buyers: Int, countCourses: Int, id: Int) {
        self.name = name
        self.procent = procent
        self.dateStart = dateStart
        self.dateEnd = dateEnd
        self.buyers = buyers
        self.countCourses = countCourses
        self.id = id
    }
    
    init() {
        self.name = ""
        self.procent = 0
        self.dateStart = ""
        self.dateEnd = ""
        self.buyers = 0
        self.countCourses = 0
        self.id = 0
    }
    
    func deletePromocode(_ promocode: Promocodes) async throws {
        let url = Constants.url + "api/v1/courses/\(promocode.id)/delete-promo/"
        let headers: HTTPHeaders = ["Authorization": "Bearer \(User.info.token)"]
        
        let response = AF.request(url, method: .delete, headers: headers).serializingData()
        
        let value = try await response.value
        let code = await response.response.response?.statusCode
        let json = JSON(value)
        
        if code != 204 {
            throw ErrorNetwork.runtimeError(json["detail"].stringValue)
            
        }
    }
    
    func usedPromocode(_ promocodeName: String, courseID: Int) async throws -> Promocodes {
        let url = Constants.url + "api/v1/courses/use-promo/"
        let headers: HTTPHeaders = ["Authorization": "Bearer \(User.info.token)"]
        
        var parameters = [
            "course_id": courseID,
            "promo_name": promocodeName
        ] as [String : Any]
        let response = AF.request(url, method: .post, parameters: parameters, headers: headers).serializingData()
        
        let value = try await response.value
        let code = await response.response.response?.statusCode
        let json = JSON(value)
        
        let promo = Promocodes()
        
        promo.id = json["id"].intValue
        promo.name = json["name"].stringValue
        promo.procent = json["percent"].intValue
        
        if code != 200 {
            let error = json["error"].stringValue
            throw ErrorNetwork.runtimeError(error)
        }
        return promo
    }
    
    func createPromocode(_ promocode: Promocodes) async throws -> Promocodes {
        let url = Constants.url + "api/v1/courses/promo-create/"
        let headers: HTTPHeaders = ["Authorization": "Bearer \(User.info.token)"]
        
        var parameters = [
            "name": promocode.name,
            "percent": promocode.procent
        ] as [String : Any]
        if promocode.dateStart != nil {
            parameters["start_date"] = promocode.dateStart!
        }
        if promocode.dateEnd != nil {
            parameters["end_date"] = promocode.dateEnd!
        }
        let response = AF.request(url, method: .post, parameters: parameters, headers: headers).serializingData()
        
        let value = try await response.value
        let code = await response.response.response?.statusCode
        let json = JSON(value)
        print(json)
        if code != 201 {
            throw ErrorNetwork.runtimeError(json["detail"].stringValue)
        }
        promocode.id = json["id"].intValue
        return promocode
    }
    
    func changePromocode(_ promocode: Promocodes) async throws -> Promocodes {
        print(promocode.id)
        let url = Constants.url + "api/v1/courses/\(promocode.id)/update-promo/"
        let headers: HTTPHeaders = ["Authorization": "Bearer \(User.info.token)"]
        
        var parameters = [
            "percent": promocode.procent
        ] as [String : Any]
        if promocode.dateStart != nil {
            parameters["start_date"] = promocode.dateStart!
        }
        if promocode.dateEnd != nil {
            parameters["end_date"] = promocode.dateEnd!
        }
        let response = AF.request(url, method: .patch, parameters: parameters, headers: headers).serializingData()
        
        let value = try await response.value
        let code = await response.response.response?.statusCode
        let json = JSON(value)
        print(json)
        if code != 201 {
            throw ErrorNetwork.runtimeError(json["detail"].stringValue)
        }
        promocode.id = json["id"].intValue
        return promocode
    }
    
    func getMyPromocodes() async throws -> [Promocodes] {
        let url = Constants.url + "api/v1/courses/get-my-promo/"
        let headers: HTTPHeaders = ["Authorization": "Bearer \(User.info.token)"]
        let value = try await AF.request(url, headers: headers).serializingData().value
        
        let json = JSON(value)
        var promocodes = [Promocodes]()
        
        let results = json.arrayValue
        guard results.isEmpty == false else {return []}
        
        for x in 0...results.count - 1 {
            let promocode = Promocodes()
            promocode.id = json[x]["id"].intValue
            promocode.name = json[x]["name"].stringValue
            promocode.procent = json[x]["percent"].intValue
            promocode.dateStart = json[x]["start_date"].stringValue
            promocode.dateEnd = json[x]["end_date"].stringValue
            promocode.countCourses = json[x]["courses"].arrayValue.count
            promocodes.append(promocode)
        }
        return promocodes
    }
    
    func addPromocodesToCourses(course: Course, promocode: Promocodes) async throws {
        let url = Constants.url + "api/v1/courses/\(course.id)/assign-promo/"
        let headers: HTTPHeaders = ["Authorization": "Bearer \(User.info.token)"]
        
        let parameters = [
            "promo_code_name": promocode.name
        ]
        
        let response = AF.request(url, method: .patch, parameters: parameters, headers: headers).serializingData()
        
        let value = try await response.value
        let code = await response.response.response?.statusCode
        let json = JSON(value)
        
        print(json, code)
    }
    
    func deletePromocodesToCourses(courseID: Int, promocode: Promocodes) async throws {
        let url = Constants.url + "api/v1/courses/\(courseID)/remove-promo-from-course/"
        let headers: HTTPHeaders = ["Authorization": "Bearer \(User.info.token)"]
        
        let parameters = [
            "promo_code_name": promocode.name
        ]
        
        let response = AF.request(url, method: .patch, parameters: parameters, headers: headers).serializingData()
        
        let value = try await response.value
        let code = await response.response.response?.statusCode
        let json = JSON(value)
        
        print(json, code)
    }
    
    func getPromoToCourses(courseID: Int) async throws -> [Promocodes] {
        let url = Constants.url + "api/v1/courses/\(courseID)/get-course-promo/"
        let headers: HTTPHeaders = ["Authorization": "Bearer \(User.info.token)"]
        
        let value = try await AF.request(url, headers: headers).serializingData().value
        
        let json = JSON(value)
        var promocodes = [Promocodes]()
        
        let results = json.arrayValue
        guard results.isEmpty == false else {return []}
        
        for x in 0...results.count - 1 {
            let promocode = Promocodes()
            promocode.id = json[x]["id"].intValue
            promocode.name = json[x]["name"].stringValue
            promocode.procent = json[x]["percent"].intValue
            promocode.dateStart = json[x]["start_date"].stringValue
            promocode.dateEnd = json[x]["end_date"].stringValue
            promocodes.append(promocode)
        }
        return promocodes
    }
    
}
