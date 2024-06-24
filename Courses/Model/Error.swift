//
//  Error.swift
//  Courses
//
//  Created by Руслан on 23.06.2024.
//

import Foundation

enum ErrorNetwork: String, Swift.Error {
    case invalidLogin = "Неправильный логин"
    case notFound = "Ошибка данных"
    case tryAgainLater = "Повторите попытку позже"
    case invalidPassword = "Пароль должен содержать как минимум 8 символов, хотя бы одну заглавную букву и хотя бы одну цифру."
    case userAlredyIsRegistr = "Пользователь уже зарегестрирован"
    
    static func statusCode(_ code: Int) -> ErrorNetwork {
        switch code {
        case 401: return invalidPassword
        case 502: return .invalidLogin
        case 404: return .notFound
        case 500: return .tryAgainLater
        case 501: return .invalidPassword
        case 503: return .userAlredyIsRegistr
        default:
            return .tryAgainLater
        }
    }
    
}
