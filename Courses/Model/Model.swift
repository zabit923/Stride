//
//  Model.swift
//  Courses
//
//  Created by Руслан on 23.06.2024.
//

import Foundation

class Constants {
    static let url = "http://127.0.0.1:8080/"
}

enum Role: String {
    case coach = "Coach"
    case user = "User"
    case admin = "Admin"
}

enum Alignment {
    case left
    case center
    case right
    case defaultCenter
}

struct Category {
    let nameCategory: String
    let image: String
}

struct Course {
    let daysCount: Int
    let progressInPercents: Int
    let progressInDays: Int
    let nameCourse: String
    let nameAuthor: String
    let price: Int
    let image: String
    let rating: Float
}

struct User {
    let name: String
    let avatar: String
    let characteristic: String
    let countCourses: Int
    let rating: Float
}
