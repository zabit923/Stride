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
        let url = Constants.url + "auth"
        let parameters: Parameters = [
            "phoneNumber": phoneNumber,
            "password": password
        ]
        
        let data = AF.request(url, method: .post, parameters: parameters).serializingData()
        guard let code = await data.response.response?.statusCode else {throw ErrorNetwork.tryAgainLater}
        if code != 200 {
            throw ErrorNetwork.statusCode(code)
        }
        
    }
    
    func registr(phoneNumber:String, password:String, name:String, lastName:String, mail:String) async throws {
        
        let url = Constants.url + "auth" + "/create"
        let parameters: Parameters = [
            "phoneNumber": phoneNumber,
            "password": password,
            "role": Role.user.rawValue,
            "firstName": name,
            "lastName": lastName
        ]
        
        let data = AF.request(url, method: .post, parameters: parameters).serializingData()
        guard let code = await data.response.response?.statusCode else {throw ErrorNetwork.tryAgainLater}
        if code != 200 {
            throw ErrorNetwork.statusCode(code)
        }
    }
    
}
