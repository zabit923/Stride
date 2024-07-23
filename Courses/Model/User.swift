//
//  User.swift
//  Courses
//
//  Created by Руслан on 19.07.2024.
//

import Foundation
import Alamofire
import SwiftyJSON


class User {
    
    func getMyInfo(token: String) async throws {
        let url = Constants.url + "api/v1/users/me/"
        let headers: HTTPHeaders = ["Authorization": "Bearer \(token)"]
        let value = try await AF.request(
            url,method: .get,
            headers: headers
        ).serializingData().value
        let json = JSON(value)
        var user = UserStruct()
        user.name = json["first_name"].stringValue
        user.surname = json["last_name"].stringValue
        user.email = json["email"].stringValue
        user.phone = json["username"].stringValue
        UD().saveMyInfo(user)
    }
    
    func getUserByID(id:String) async throws {
        let url = Constants.url + "api/v1/users/\(id)"
        let value = try await AF.request(url).serializingData().value
        let json = JSON(value)
        let name = json["first_name"]
        let surname = json["last_name"]
        let email = json["email"]
    }
}
