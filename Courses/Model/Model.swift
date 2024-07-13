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
    static let url = "http://127.0.0.1:8080/"
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

struct User {
    var role: Role
    var name: String?
    var avatar: String?
    var myCourses = [Course]()
}

struct Coach {
    var name: String
    var avatar: String?
    var description: String?
    var countCourses: Int = 0
    var rating: Float = 0.0
    var myCourses = [Course]()
}

