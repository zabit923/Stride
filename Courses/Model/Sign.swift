//
//  Sign.swift
//  Courses
//
//  Created by Руслан on 23.06.2024.
//

import Foundation
import Alamofire
import SwiftyJSON


class Sign {
    
    func vhod(phoneNumber: String, password:String) async throws {
        let url = Constants.url + "api/token/"
        let parameters: Parameters = [
            "username": phoneNumber,
            "password": password
        ]
        
        let data = AF.request(url, method: .post, parameters: parameters).serializingData()
        guard let code = await data.response.response?.statusCode else {throw ErrorNetwork.tryAgainLater}
        let json = try await JSON(data.value)
        if code == 200 {
            try await User().getMyInfo(token: json["access"].stringValue)
            UD().saveCurrent(true)
        }else {
            throw ErrorNetwork.runtimeError("Неправильный номер или пароль")
        }
        
    }
    
    
    
    func registr(phoneNumber:String, password:String, name:String, lastName:String, mail:String) async throws {
        
        let url = Constants.url + "api/v1/users/"
        let parameters = [
          "username": phoneNumber,
          "email": mail,
          "first_name": name,
          "last_name": lastName,
          "is_coach": false,
          "phone": phoneNumber,
          "password": password,
          "password_again": password
        ] as [String : Any]
        
        let data = AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default).serializingData()
        let value = try await data.value
        let json = JSON(value)
        print(json)
        guard let code = await data.response.response?.statusCode else {throw ErrorNetwork.tryAgainLater}
        if code == 201 {
            UD().saveMyInfo(UserStruct(role: .user, name: name, surname: lastName, email: mail, phone: phoneNumber))
            UD().saveCurrent(true)
        }else {
            let error = json.dictionary!.first!.value[0].stringValue
            throw ErrorNetwork.runtimeError(error)
        }
    }
    
}
