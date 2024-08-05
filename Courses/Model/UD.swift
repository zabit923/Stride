//
//  UD.swift
//  Courses
//
//  Created by Ибрагимов Эльдар on 13.07.2024.
//

import Foundation

class UD {
    
    func saveToken(_ token:String) {
        UserDefaults.standard.set(token, forKey: "token")
    }
    
    func saveMyInfo(_ user: UserStruct) {
        UserDefaults.standard.set(user.name, forKey: "myName")
        UserDefaults.standard.set(user.surname, forKey: "mySurname")
        var role = user.role
        if user.isCoach == true {
            role = .coach
        }else {
            role = .user
        }
        UserDefaults.standard.set(role.rawValue, forKey: "myRole")
        UserDefaults.standard.set(user.email, forKey: "myEmail")
        UserDefaults.standard.set(user.phone, forKey: "myPhoneNumber")
        UserDefaults.standard.set(user.id, forKey: "myID")
        UserDefaults.standard.set(user.isCoach, forKey: "isCoach")
        UserDefaults.standard.set(user.coach.description, forKey: "coachDescription")
    }
    
    func getMyInfo() -> UserStruct {
        var user = UserStruct()
        user.name = UserDefaults.standard.string(forKey: "myName") ?? ""
        user.surname = UserDefaults.standard.string(forKey: "mySurname") ?? ""
        user.role = Role(rawValue: UserDefaults.standard.string(forKey: "myRole") ?? "user") ?? .user
        user.email = UserDefaults.standard.string(forKey: "myEmail") ?? ""
        user.phone = UserDefaults.standard.string(forKey: "myPhoneNumber") ?? ""
        user.id = UserDefaults.standard.integer(forKey: "myID")
        user.token = UserDefaults.standard.string(forKey: "token") ?? ""
        user.isCoach = UserDefaults.standard.bool(forKey: "isCoach")
        user.coach.description = UserDefaults.standard.string(forKey: "coachDescription")
        if UserDefaults.standard.string(forKey: "birthday") != "" {
            user.birthday = UserDefaults.standard.string(forKey: "birthday")
        }
        if UserDefaults.standard.double(forKey: "height") != 0.0 {
            user.height = UserDefaults.standard.double(forKey: "height")
        }
        if UserDefaults.standard.double(forKey: "weight") != 0.0 {
            user.weight = UserDefaults.standard.double(forKey: "weight")
        }
        if let level = UserDefaults.standard.string(forKey: "level") {
            user.level = Level(rawValue: level)
        }
        if let goal = UserDefaults.standard.string(forKey: "goal") {
            user.goal = Goal(rawValue: goal)
        }
        return user
    }
    
    func saveCurrent(_ current:Bool) {
        UserDefaults.standard.set(current, forKey: "current")
    }
    
    func getCurrent() -> Bool {
        let current = UserDefaults.standard.bool(forKey: "current")
        return current
    }
    
    
    
    func saveInfoAboutMe(_ user: UserStruct) {
        UserDefaults.standard.set(user.birthday, forKey: "birthday")
        UserDefaults.standard.set(user.height, forKey: "height")
        UserDefaults.standard.set(user.weight, forKey: "weight")
        if let level = user.level {
            UserDefaults.standard.set(level.rawValue, forKey: "level")
        }else {
            UserDefaults.standard.set(nil, forKey: "level")
        }
        if let goal = user.goal {
            UserDefaults.standard.set(goal.rawValue, forKey: "goal")
        }else {
            UserDefaults.standard.set(nil, forKey: "goal")
        }
    }
    
    func clearUD() {
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            defaults.removeObject(forKey: key)
        }
    }
    
}
