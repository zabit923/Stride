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
    
    static var info: UserStruct {
        return UD().getMyInfo()
    }
    
    
    func changeInfoUser(id: Int, user: UserStruct) async throws {
        let url = Constants.url + "api/v1/users/\(id)/"
        let headers: HTTPHeaders = ["Authorization": "Bearer \(User.info.token)"]
        let response = AF.upload(multipartFormData: { multipartFormData in
            if let avatarURL = user.avatarURL {
                multipartFormData.append(avatarURL, withName: "image")
            }
            multipartFormData.append(Data(user.name.utf8), withName: "first_name")
            multipartFormData.append(Data(user.surname.utf8), withName: "last_name")
            multipartFormData.append(Data(user.phone.utf8), withName: "phone_number")
            multipartFormData.append(Data(user.email.utf8), withName: "email")
            multipartFormData.append(Data(user.coach.description!.utf8), withName: "desc")
        }, to: url, method: .patch, headers: headers).serializingData()
        let value = try await response.value
        let code = await response.response.response?.statusCode
        let json = JSON(value)
        if code != 200 {
            let error = json.dictionary!.first!.value[0].stringValue
            throw ErrorNetwork.runtimeError(error)
        }
        UD().saveMyInfo(user)
    }
    
    func changeInfoAboutMe(id: Int, user: UserStruct) async throws {
        let url = Constants.url + "api/v1/users/\(id)/"
        try await doubleRequest(url: url, user: user)
        try await stringRequest(url: url, user: user)
        UD().saveInfoAboutMe(user)
    }
    
    private func doubleRequest(url:String, user: UserStruct) async throws {
        let parameters = [
            "height": user.height,
            "weight": user.weight,
        ]
        let _ = try await AF.request(url, method: .patch, parameters: parameters, encoder: JSONParameterEncoder.default).serializingData().value
    }
    
    private func stringRequest(url:String, user: UserStruct) async throws {
        let parameters = [
            "date_of_birth": user.birthday,
            "target": user.goal?.rawValue,
            "level": user.level?.rawValue
        ]
        let _ = try await AF.request(url, method: .patch, parameters: parameters, encoder: JSONParameterEncoder.default).serializingData().value
    }

    
    func getMyInfo() async throws -> UserStruct  {
        let url = Constants.url + "api/v1/users/me/"
        let headers: HTTPHeaders = ["Authorization": "Bearer \(User.info.token)"]
        let value = try await AF.request(
            url,method: .get,
            headers: headers
        ).serializingData().value
        let json = JSON(value)
        var user = UserStruct()
        user.name = json["first_name"].stringValue
        user.surname = json["last_name"].stringValue
        user.email = json["email"].stringValue
        user.phone = json["phone_number"].stringValue
        user.id = json["id"].intValue
        user.height = json["height"].doubleValue
        user.weight = json["weight"].doubleValue
        user.birthday = json["date_of_birth"].stringValue
        user.goal = Goal(rawValue: json["target"].stringValue)
        user.level = Level(rawValue: json["level"].stringValue)
        user.isCoach = json["is_coach"].boolValue
        user.coach.description = json["desc"].stringValue
        user.avatarURL = URL(string: "http://127.0.0.1:8000\(json["image"].stringValue)")
        if user.isCoach == true {
            user.role = .coach
        }else {
            user.role = .user
        }
        UD().saveMyInfo(user)
        UD().saveInfoAboutMe(user)
        return user
    }
    
    func getUserByID(id: Int) async throws -> UserStruct {
        let url = Constants.url + "api/v1/users/\(id)"
        let value = try await AF.request(url).serializingData().value
        let json = JSON(value)
        var user = UserStruct()
        user.name = json["first_name"].stringValue
        user.surname = json["last_name"].stringValue
        user.email = json["email"].stringValue
        user.phone = json["phone_number"].stringValue
        user.id = json["id"].intValue
        user.avatarURL = URL(string: json["image"].stringValue)
        return user
    }
}
