//
//  Realm.swift
//  Courses
//
//  Created by Руслан on 16.08.2024.
//

import Foundation
import Realm
import RealmSwift
import UIKit
import SDWebImage

// MARK: - Main Class

class RealmValue {

    private let realm = try! Realm()

    func addCompletedModule(course: Course, module: Modules) {
        let realmModule = RealmModulesCompleted(idCourse: course.id, moduleID: module.id)
        try! realm.write {
            realm.add(realmModule)
        }
        RealmValue().addCompletedDays(course: course)
    }


    func addCompletedDays(course: Course) -> Course {
        let completedModules = realm.objects(RealmModulesCompleted.self).filter("idCourse == %@", course.id)
        var result = course
        var countDaysCompleted = 0
        guard result.courseDays.isEmpty == false else { return result }
        for x in 0...result.courseDays.count - 1 {
            if compareModules(days: result.courseDays[x], completedModules: completedModules) && result.courseDays[x].modules.isEmpty == false {
                result.courseDays[x].type = .before
                countDaysCompleted += 1
            }else {
                result.courseDays[x].type = .noneSee
            }
        }
        UD().saveDaysCompletedInCourse(course: course, countDaysCompleted: countDaysCompleted)
        return result
    }


    private func compareModules(days: CourseDays, completedModules: Results<RealmModulesCompleted>) -> Bool {
        let moduleIDsInDay = days.modules.map { $0.id }
        let allModulesCompleted = moduleIDsInDay.allSatisfy { moduleID in
            completedModules.contains(where: { $0.moduleID == moduleID })
        }
        return allModulesCompleted
    }

    func clearRealm() {
        let realm = try! Realm()

        do {
            try realm.write {
                realm.deleteAll()
            }
        } catch {
            print("Ошибка при очистке Realm: \(error)")
        }
    }

}

class RealmModulesCompleted: Object {
    @Persisted var idCourse: Int
    @Persisted var moduleID: Int

    required override init() {
        super.init()
    }


    init(idCourse: Int, moduleID: Int) {
        self.idCourse = idCourse
        self.moduleID = moduleID
    }
}

class CourseCompletedDays: Object {
    @Persisted(primaryKey: true) var courseId: Int = 0
    @Persisted var completedDays: Int = 0
}
