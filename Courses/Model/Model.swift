//
//  Model.swift
//  Courses
//
//  Created by Руслан on 23.06.2024.
//

import Foundation
import UIKit

struct Objects {
    let name: String
    let image: String
}

class Constants {
    static let url = "http://127.0.0.1:8000/"
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

struct Category {
    var nameCategory: String
    var image: String
}

struct Course {
    var daysCount: Int
    var progressInPercents: Int
    var progressInDays: Int
    var nameCourse: String
    var nameAuthor: String
    var price: Int
    var image: String
    var rating: Float
}

struct UserStruct {
    var role: Role
    var name: String
    var surname: String
    var email: String
    var phone: String
    var height: Double?
    var weight: Double?
    var birthday: String?
    var description: String?
    var avatar: String?
    var level: Level?
    var goal: Goal?
    var myCourses = [Course]()
    
    init(role: Role = .user, name: String = "", surname: String = "", email: String = "", phone: String = "") {
        self.role = role
        self.name = name
        self.surname = surname
        self.email = email
        self.phone = phone
    }
    
    init(role: Role, name: String, surname: String, email: String, phone: String, height: Double? = nil, weight: Double? = nil, birthday: String? = nil, description: String? = nil, avatar: String? = nil, level: Level? = nil, goal: Goal? = nil, myCourses: [Course] = [Course]()) {
        self.role = role
        self.name = name
        self.surname = surname
        self.email = email
        self.phone = phone
        self.height = height
        self.weight = weight
        self.birthday = birthday
        self.description = description
        self.avatar = avatar
        self.level = level
        self.goal = goal
        self.myCourses = myCourses
    }
}

enum Level {
    case beginner
    case middle
    case advanced
    case professional
}

enum Goal {
    case loseWeight
    case gainWeight
    case health
    case other
}

struct Coach {
    var name: String
    var avatar: String?
    var description: String?
    var countCourses: Int = 0
    var rating: Float = 0.0
    var myCourses = [Course]()
}

