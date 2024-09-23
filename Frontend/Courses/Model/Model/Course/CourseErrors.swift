//
//  CourseErrors.swift
//  Courses
//
//  Created by Руслан on 23.09.2024.
//

import Foundation
import SwiftyJSON

class CourseErrors {
    
    func error(value: Data) throws {
        let json = JSON(value)
        if let dictionary = json.dictionary {
            let error = dictionary.first!.value[0].stringValue
            throw ErrorNetwork.runtimeError(error)
        }else {
            throw ErrorNetwork.runtimeError("Неизвестная ошибка")
        }
    }
}
