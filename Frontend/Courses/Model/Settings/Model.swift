//
//  Model.swift
//  Courses
//
//  Created by Руслан on 23.06.2024.
//

import Foundation
import UIKit


class Constants {
    static let url = "https://stridecourses.ru/"
    static let telegramURL = URL(string: "https://t.me/StrideCoursesBot")!
}

// MARK: - Collection
struct Banks {
    let name: String
    let image: String
}

struct Objects {
    let name: String
    let image: String
    let imageForBtn: String
}

struct Category {
    var nameCategory: String
    var imageURL: URL
    var id: Int
}


// MARK: - User
struct UserStruct {
    var role: Role
    var name: String
    var surname: String
    var email: String
    var phone: String
    var height: Double?
    var weight: Double?
    var birthday: String?
    var avatarURL: URL?
    var level: Level?
    var goal: Goal?
    var coach = Coach()
    var isCoach: Bool?
    var myCourses = [Course]()
    var id = 0
    var token = ""

    init(role: Role = .user, name: String = "", surname: String = "", email: String = "", phone: String = "", id: Int = 0) {
        self.role = role
        self.name = name
        self.surname = surname
        self.email = email
        self.phone = phone
    }

    init(role: Role, name: String, surname: String, email: String, phone: String, height: Double? = nil, weight: Double? = nil, birthday: String? = nil, description: String? = nil, avatarURL: URL? = nil, level: Level? = nil, goal: Goal? = nil, myCourses: [Course] = [Course](), id: Int = 0) {
        self.role = role
        self.name = name
        self.surname = surname
        self.email = email
        self.phone = phone
        self.height = height
        self.weight = weight
        self.birthday = birthday
        self.avatarURL = avatarURL
        self.level = level
        self.goal = goal
        self.myCourses = myCourses
    }
}

struct Coach {
    var description: String?
    var countCourses: Int = 0
    var rating: Float = 0.0
    var myCourses = [Course]()
    var money: Int = 0
}

struct InfoMe: Encodable {
    var level: String?
    var goal: String?
    var height: Double?
    var weight: Double?
    var date_of_birth: String?
}


// MARK: - Comments

struct Reviews {
    var id: Int
    var author: String
    var authorAvatar: URL?
    var text: String
    var date: String
    var courseID: Int
}

// MARK: - enum
enum Level: String {
    case beginner = "BEG"
    case middle = "MID"
    case advanced = "ADV"
    case professional = "PRO"

    func thirdString() -> String {
        switch self {
        case .beginner:
            return "Начинающий"
        case .middle:
            return "Средний"
        case .advanced:
            return "Прогрессивный"
        case .professional:
            return "Профессиональный"
        }
    }

    static func thirdLevel(_ level: String) -> Level? {
        switch level {
        case "Начинающий":
            return .beginner
        case "Средний":
            return .middle
        case "Прогрессивный":
            return .advanced
        case "Профессиональный":
            return .professional
        default:
            return nil
        }
    }
}

enum TypeDays: String {
    case current = "current"
    case before = "before"
    case noneSee = "noneSee"

    init?(rawValue: String) {
        switch rawValue {
        case "current": self = .current
        case "before": self = .before
        case "noneSee": self = .noneSee
        default: return nil
        }
    }

}

enum PaymentMethod {
    case card(cardNumber: String, amount: Int)
    case sbp(phoneNumber: String, amount: Int, bank: String)

    var cardNumber: String? {
        if case .card(let number, _) = self {
            return number
        }
        return nil
    }

    var amount: Int {
        switch self {
        case .card(_, let amount):
            return amount
        case .sbp(_, let amount, _):
            return amount
        }
    }

    var phoneNumber: String? {
        if case .sbp(let number, _, _) = self {
            return number
        }
        return nil
    }

    var bank: String? {
        if case .sbp(_, _, let bank) = self {
            return bank
        }
        return nil
    }
    
}


enum Goal: String {
    case loseWeight = "LW"
    case gainWeight = "GW"
    case health = "HL"
    case other = "OT"

    func thirdString() -> String {
        switch self {
        case .loseWeight:
            return "Похудеть"
        case .gainWeight:
            return "Набрать мышечную массу"
        case .health:
            return "Здоровье"
        case .other:
            return "Другое"
        }
    }

    static func thirdGoal(_ goal: String) -> Goal? {
        switch goal {
        case "Похудеть":
            return .loseWeight
        case "Набрать мышечную массу":
            return .gainWeight
        case "Здоровье":
            return .health
        case "Другое":
            return .other
        default:
            return nil
        }
    }
}

enum Role: String {
    case coach = "Coach"
    case user = "User"
    case admin = "Admin"
}

enum Picker {
    case birthday
    case levelPreparation
    case intention
}

enum Alignment {
    case left
    case center
    case right
    case defaultCenter
}

enum CourseCatalog {
    case myCreate
    case recomend
    case popular
    case celebrity
}

enum SelectBtn {
    case firstButton
    case secondButton
    case thirdButton
    case fourtFutton
    case fifthButton
}

enum DeepLinking: String {
    case course = "courses"
    case user = "user"
}

// MARK: - Protocol

protocol ChangeInfoModule: AnyObject {
    func changeInfoModuleDismiss(module: Modules, moduleID: Int)
    func deleteModuleDismiss(moduleID: Int)
}

protocol AddCategoryDelegate: AnyObject {
    func category(category: Category)
}
