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
        print(code)
        if code == 200 {
            UD().saveCurrent(true)
        }else {
            throw ErrorNetwork.statusCode(code)
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
        print(JSON(try await data.value))
        guard let code = await data.response.response?.statusCode else {throw ErrorNetwork.tryAgainLater}
        if code == 201 {
            UD().saveCurrent(true)
        }else {
            throw ErrorNetwork.statusCode(code)
        }
    }
    
}
