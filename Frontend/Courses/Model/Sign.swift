//
//  Sign.swift
//  Courses
//
//  Created by Руслан on 23.06.2024.
//

import Foundation
import Alamofire
import SwiftyJSON
import GoogleSignIn


class Sign {
    
    // MARK: - Google
    
    func signGoogle(_ viewController: UIViewController) {
        let clientID = "477842031879-ts6fncapcq8u6nvb4p0237i4kk2tnlgp.apps.googleusercontent.com"
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        GIDSignIn.sharedInstance.signIn(withPresenting: viewController) { result, error in
            guard error == nil else { return }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else { return }
            
            let accessToken = user.accessToken.tokenString
            
            guard let name = user.profile?.name else {return}
            guard let email = user.profile?.email else {return}
            
            Task {
                try await self.saveInBD(token: idToken, name: name, email: email)
            }
        }
    }
    
    private func saveInBD(token: String, name: String, email: String) async throws {
        let url = Constants.url + "api/v1/oauth/google/"
        let parameters = [
              "username": name,
              "email": email,
              "token": token
        ]
        let value = try await AF.request(url, method: .post, parameters: parameters).serializingData().value
        let json = JSON(value)
    }
    
    
    // MARK: - Base Sign
    func vhod(phoneNumber: String, password:String) async throws {
        let url = Constants.url + "api/token/"
        let parameters: Parameters = [
            "phone_number": phoneNumber,
            "password": password
        ]
        
        let data = AF.request(url, method: .post, parameters: parameters).serializingData()
        
        let json = try await JSON(data.value)
        let tokenAccess = json["access"].stringValue
        guard let code = await data.response.response?.statusCode else {throw ErrorNetwork.tryAgainLater}
        
        if code == 200 {
            UD().saveToken(tokenAccess)
            let _ = try await User().getMyInfo()
            UD().saveCurrent(true)
        }else {
            throw ErrorNetwork.runtimeError("Неправильный номер или пароль")
        }
        
    }
    
    
    
    func registr(phoneNumber:String, password:String, name:String, lastName:String, mail:String) async throws {
        let url = Constants.url + "api/v1/users/"
        let parameters = [
          "phone_number": phoneNumber,
          "email": mail,
          "first_name": name,
          "last_name": lastName,
          "is_coach": false,
          "password": password,
          "password_again": password
        ] as [String : Any]
        
        let data = AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default).serializingData()
        let value = try await data.value
        
        let json = JSON(value)
        let tokenAccess = json["token"]["access"].stringValue
        
        guard let code = await data.response.response?.statusCode else {throw ErrorNetwork.tryAgainLater}
        
        if code == 201 {
            UD().saveToken(tokenAccess)
            let _ = try await User().getMyInfo()
            UD().saveCurrent(true)
        }else {
            let error = json.dictionary!.first!.value[0].stringValue
            throw ErrorNetwork.runtimeError(error)
        }
        
    }
    
}
