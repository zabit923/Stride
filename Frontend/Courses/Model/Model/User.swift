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
                ImageResize.compressImageFromFileURL(fileURL: avatarURL, maxSizeInMB: 0.1) { compressedURL in
                    if let url = compressedURL {
                        multipartFormData.append(url, withName: "image")
                    }
                }
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
            if let dictionary = json.dictionary {
                let error = dictionary.first!.value[0].stringValue
                throw ErrorNetwork.runtimeError(error)
            }else {
                throw ErrorNetwork.runtimeError("Неизвестная ошибка")
            }
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
        let headers: HTTPHeaders = ["Authorization": "Bearer \(User.info.token)"]
        let _ = try await AF.request(url, method: .patch, parameters: parameters, encoder: JSONParameterEncoder.default, headers: headers).serializingData().value
    }

    private func stringRequest(url:String, user: UserStruct) async throws {
        let parameters = [
            "date_of_birth": user.birthday,
            "target": user.goal?.rawValue,
            "level": user.level?.rawValue
        ]
        let headers: HTTPHeaders = ["Authorization": "Bearer \(User.info.token)"]
        let _ = try await AF.request(url, method: .patch, parameters: parameters, encoder: JSONParameterEncoder.default,headers: headers).serializingData().value
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
        user.coach.description = json["desc"].stringValue
        user.coach.money = json["balance"].intValue
        user.avatarURL = URL(string: "\(json["image"].stringValue)")
        let isCoach = json["is_coach"].boolValue
        let admin = json["is_staff"].boolValue
        if admin == true {
            user.role = .admin
        }else if isCoach == true {
            user.role = .coach
        }else if isCoach == false {
            user.role = .user
        }
        UD().saveMyInfo(user)
        UD().saveInfoAboutMe(user)
        return user
    }

    func getUserByID(id: Int) async throws -> UserStruct {
        let url = Constants.url + "api/v1/users/\(id)/"
        let headers: HTTPHeaders = ["Authorization": "Bearer \(User.info.token)"]
        let value = try await AF.request(url, headers: headers).serializingData().value
        let json = JSON(value)
        var user = UserStruct()
        user.name = json["first_name"].stringValue
        user.surname = json["last_name"].stringValue
        user.email = json["email"].stringValue
        user.phone = json["phone_number"].stringValue
        user.id = json["id"].intValue
        user.coach.description = json["desc"].stringValue
        user.avatarURL = URL(string: json["image"].stringValue)
        return user
    }

    func getCelebreties() async throws -> [UserStruct] {
        let url = Constants.url + "api/v1/users/get_all_celebrity/"
        let headers: HTTPHeaders = ["Authorization": "Bearer \(User.info.token)"]
        let value = try await AF.request(url, headers: headers).serializingData().value
        let json = JSON(value)
        var celebrities = [UserStruct]()
        let array = json.arrayValue
        guard array.isEmpty == false else {return []}
        for x in 0...array.count - 1 {
            let name = json[x]["first_name"].stringValue
            let surname = json[x]["last_name"].stringValue
            let email = json[x]["email"].stringValue
            let phone = json[x]["phone_number"].stringValue
            let image = "\(json[x]["image"].stringValue)"
            var role = Role.user
            let isCoach = json["is_coach"].boolValue
            let admin = json["is_staff"].boolValue
            if admin == true {
                role = .admin
            }else if isCoach == true {
                role = .coach
            }else if isCoach == false {
                role = .user
            }
            celebrities.append(UserStruct(role: role, name: name, surname: surname, email: email, phone: phone, avatarURL: URL(string: image)))
        }
        return celebrities
    }
    
    func deleteAccount() async throws {
        let url = Constants.url + "api/v1/users/delete-profile/"
        let headers: HTTPHeaders = ["Authorization": "Bearer \(User.info.token)"]
        
        let response = AF.request(url, method: .delete, headers: headers).serializingData()
        let code = await response.response.response?.statusCode
        
        if code != 204 {
            throw ErrorNetwork.runtimeError("Ошибка")
        }
    }
}
