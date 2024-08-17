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
    
    func dayCompleted(courseID: Int, day: Int) {
        let realm = try! Realm()
        guard let moduleRealm = realm.object(ofType: RealmCourse.self, forPrimaryKey: courseID) else { return }
        for x in moduleRealm.courseDays {
            if x.day == day {
                try! realm.write {
                    x.type = checkTypeDay(days: x).rawValue
                }
            }
        }
    }
    
    func moduleCompleted(moduleID: Int, courseID: Int) {
        let realm = try! Realm()
        guard let moduleRealm = realm.object(ofType: RealmCourse.self, forPrimaryKey: courseID) else { return }
        for x in moduleRealm.courseDays {
            for y in x.modules {
                if y.id == moduleID {
                    try! realm.write {
                        y.isRead = true
                    }
                }
            }
            dayCompleted(courseID: courseID, day: x.day)
        }
    }
    
    private func checkTypeDay(days: RealmCourseDays) -> TypeDays {
        var result = true
        for x in 0...days.modules.count - 1 {
            if days.modules[x].isRead == false {
                result = false
            }
        }
        if result {
            return .before
        }else {
            return .noneSee
        }
    }
    
    func saveDaysAndModels(courses: Course) {
        let realm = try! Realm()
        guard let courseInRealm = realm.object(ofType: RealmCourse.self, forPrimaryKey: courses.id) else { return }

        try! realm.write {
            let existingDays = Set(courseInRealm.courseDays.map { $0.day })

            for day in courses.courseDays {
                if !existingDays.contains(day.day) {
                    let days = RealmCourseDays()
                    days.day = day.day
                    days.type = day.type.rawValue

                    let modulesList = List<RealmModules>()
                    for x in day.modules {
                        let module = RealmModules()
                        module.name = x.name
                        module.minutes = x.minutes
                        module.desc = x.description
                        module.id = x.id
                        module.isRead = x.isRead
                        module.imageURL = x.imageURL?.absoluteString
                        modulesList.append(module)
                    }
                    days.modules = modulesList
                    courseInRealm.courseDays.append(days)
                }
            }
        }
    }

    
    func getDaysAndModules(id: Int) -> Course {
        let realm = try! Realm()
        guard let courseInRealm = realm.object(ofType: RealmCourse.self, forPrimaryKey: id) else { return Course() }
        var course = Course(nameCourse: courseInRealm.nameCourse, nameAuthor: courseInRealm.nameAuthor, id: courseInRealm.id)
        course.courseDays = realmDaysInDays(days: courseInRealm.courseDays)
        return course
    }
    
    private func realmDaysInDays(days: List<RealmCourseDays>) -> [CourseDays] {
        var courseDays = [CourseDays]()
        for x in days {
            courseDays.append(CourseDays(day: x.day, type: TypeDays(rawValue: x.type)!, modules: realmModulesInModules(modulesRealm: x.modules)))
        }
        return courseDays
    }
    
    private func realmModulesInModules(modulesRealm: List<RealmModules>) -> [Modules] {
        var modules = [Modules]()
        for x in modulesRealm {
            modules.append(Modules(name: x.name, minutes: x.minutes, description: x.desc, id: x.id, isRead: x.isRead))
        }
        return modules
    }
    
    func saveCoursesInfo(courses: [Course]) {
        for x in courses {
            let imageName = "courseImage_\(x.id)"
            if let image = loadImageFromURL(url: x.imageURL!) {
                saveImage(image: image, imageName: imageName)
            }
            let courseRealm = RealmCourse(course: x)
            let realm = try! Realm()
            addCourseInRealm(realm: realm, course: courseRealm)
        }
        
    }
    
    
    private func addCourseInRealm(realm: Realm, course: RealmCourse) {
        if realm.object(ofType: RealmCourse.self, forPrimaryKey: course.id) == nil {
            try! realm.write {
                realm.add(course)
            }
        }
    }
    
    private func loadImageFromURL(url: URL) -> UIImage? {
        do {
            let data = try Data(contentsOf: url)
            return UIImage(data: data)
        } catch {
            print("Ошибка при загрузке картинки: \(error)")
            return nil
        }
    }

    
    func saveCourse(course: Course, image: UIImage) {
         let imageName = "courseImage_\(course.id)"
         saveImage(image: image, imageName: imageName)
         let realm = try! Realm()
         try! realm.write {
             let realmCourse = RealmCourse(course: course)
             realmCourse.imageURL = imageName
             realm.add(realmCourse)
         }
     }
    
    func saveImage(image: UIImage, imageName: String) {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent(imageName)
        if let data = image.jpegData(compressionQuality: 0.8) {
            try? data.write(to: fileURL)
        }
    }
    
    func loadImage(from imagePath: String) -> URL? {
          let fileManager = FileManager.default
          let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
          let fileURL = documentsURL.appendingPathComponent(imagePath)
          return fileURL
      }
    
    func getCoursesInfo() -> [Course] {
        let realm = try! Realm()
        let realmCourses = realm.objects(RealmCourse.self)
        var course = [Course]()
        for x in realmCourses {
            course.append(Course(daysCount: x.daysCount, nameCourse: x.nameCourse, nameAuthor: x.nameAuthor, imageURL: loadImage(from: x.imageURL), rating: x.rating, id: x.id, progressInDays: x.progressInDays))
        }
        return course
    }
    
    func clearRealmAndPhotos() {
        let realm = try! Realm()

        do {
            try realm.write {
                realm.deleteAll()
            }
        } catch {
            print("Ошибка при очистке Realm: \(error)")
        }

        clearPhotosInDocumentsDirectory()
    }

    private func clearPhotosInDocumentsDirectory() {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        let fileURLs = try! fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)

        for fileURL in fileURLs {
            try? fileManager.removeItem(at: fileURL)
        }
    }

}

// MARK: - Realm Class

class RealmCourse: Object {
    @Persisted var nameCourse: String
    @Persisted var nameAuthor: String
    @Persisted var rating: Float?
    @Persisted var imageURL: String
    @Persisted(primaryKey: true) var id: Int
    @Persisted var daysCount: Int
    @Persisted var progressInDays: Int
    @Persisted var courseDays = List<RealmCourseDays>()
    
    required override init() {
        super.init()
    }
    
    convenience init(course: Course) {
        self.init()
        nameCourse = course.nameCourse
        nameAuthor = course.nameAuthor
        rating = course.rating
        id = course.id
        imageURL = "courseImage_\(course.id)"
        daysCount = course.daysCount
        progressInDays = course.progressInDays
    }
    
}

class RealmCourseDays: Object {
    @Persisted var day: Int
    @Persisted var type: String
    @Persisted var modules = List<RealmModules>()
    
    init(day: Int, type: TypeDays, modules: List<RealmModules> = List<RealmModules>()) {
        self.day = day
        self.type = type.rawValue
        self.modules = modules
    }
    
    required override init() {
        super.init()
    }
    
    convenience init(courseDays: CourseDays) {
        self.init()
        day = courseDays.day
        type = courseDays.type.rawValue
    }
}

class RealmModules: Object {
    @Persisted var text: Data?
    @Persisted var name: String
    @Persisted var minutes: Int
    @Persisted var imageURL: String?
    @Persisted var desc: String?
    @Persisted var id: Int
    @Persisted var isRead: Bool = false
}

