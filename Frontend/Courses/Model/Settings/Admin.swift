//
//  Admin.swift
//  Courses
//
//  Created by Руслан on 29.10.2024.
//

import Foundation
import Alamofire
import SwiftyJSON


class Admin {
    
    private var json = CourseJSON()
    
    func getNonVerificationCourses() async throws -> [Course] {
        let url = Constants.url + "api/v1/courses/non_verification_courses/"
        let headers: HTTPHeaders = ["Authorization": "Bearer \(User.info.token)"]
        
        let value = try await AF.request(url, headers: headers).serializingData().value
        let courses = json.allCourses(value: value)
        
        return courses
    }
    
    func cancelCourses(idCourses: Int) async throws {
        let url = Constants.url + "api/v1/courses/\(idCourses)/reject_course/"
        let headers: HTTPHeaders = ["Authorization": "Bearer \(User.info.token)"]
        let response = AF.request(url, method: .post, headers: headers).serializingData()
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
    
    func successCourses(idCourses: Int) async throws {
        let url = Constants.url + "api/v1/courses/\(idCourses)/verificate_course/"
        let headers: HTTPHeaders = ["Authorization": "Bearer \(User.info.token)"]
        let response = AF.request(url, method: .post, headers: headers).serializingData()
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
    
    
    // MARK: - Payments
    
    func requestPayments() async throws -> [Payments] {
        let url = Constants.url + "api/v1/payments/"
        let headers: HTTPHeaders = ["Authorization": "Bearer \(User.info.token)"]
        let value = try await AF.request(url, method: .get, headers: headers).serializingData().value
        
        let json = JSON(value)

        
        let results = json["results"].arrayValue
        var payments = [Payments]()
        guard results.isEmpty == false else {return []}
        
        for x in 0...results.count - 1 {
            let phoneNumber = json["results"][x]["phone_number"].stringValue
            let card = json["results"][x]["card_number"].stringValue
            let bank = json["results"][x]["bank_name"].stringValue
            let amount = json["results"][x]["amount"].intValue
            let id = json["results"][x]["id"].intValue
            
            
            if phoneNumber == "" {
                let payment: PaymentMethod = .card(cardNumber: card, amount: amount)
                payments.append(Payments(paymentsInfo: payment, paymentID: id))
            }else {
                let payment: PaymentMethod = .sbp(phoneNumber: phoneNumber, amount: amount, bank: bank)
                payments.append(Payments(paymentsInfo: payment, paymentID: id))
            }
            
            
            
        }
        
        return payments
    }
    
    
    func completedPayments(id: Int) async throws {
        let url = Constants.url + "api/v1/payments/\(id)/"
        let headers: HTTPHeaders = ["Authorization": "Bearer \(User.info.token)"]
        
        let parameters = [
            "status": "Completed"
        ]
        
        let response = AF.request(url, method: .patch, parameters: parameters, headers: headers).serializingData()
        
        let value = try await response.value
        let json = JSON(value)
        let code = await response.response.response?.statusCode
        
        if code != 200 {
            if let dictionary = json.dictionary {
                let error = dictionary.first!.value[0].stringValue
                throw ErrorNetwork.runtimeError(error)
            }else {
                throw ErrorNetwork.runtimeError("Неизвестная ошибка")
            }
        }
    }
    
}
