//
//  UD.swift
//  Courses
//
//  Created by Ибрагимов Эльдар on 13.07.2024.
//

import Foundation

class UD {
    
    func saveCurrent(_ current:Bool) {
        UserDefaults.standard.set(current, forKey: "current")
    }
    
    func getCurrent() -> Bool {
        let current = UserDefaults.standard.bool(forKey: "current")
        return current
    }
    
    func saveBirthday(_ birthday: String) {
        UserDefaults.standard.set(birthday, forKey: "birthday")
    }
    
    func getBirthday() -> String? {
        guard let birthday = UserDefaults.standard.string(forKey: "birthday") else {
            return nil}
        return birthday
    }
    
    func saveLevelPraparation(_ levelPreparation: String) {
        UserDefaults.standard.set(levelPreparation, forKey: "levelPreparation")
    }
    
    func getLevelPreparation() -> String? {
        guard let levelPreparation = UserDefaults.standard.string(forKey: "levelPreparation") else {
            return nil}
        return levelPreparation
    }
    
    func saveIntention(_ intention: String) {
        UserDefaults.standard.set(intention, forKey: "intention")
    }
    
    func getIntention() -> String? {
        guard let intention = UserDefaults.standard.string(forKey: "intention") else {
            return nil}
        return intention
    }
}
