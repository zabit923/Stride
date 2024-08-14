//
//  Error.swift
//  Courses
//
//  Created by Руслан on 23.06.2024.
//

import Foundation

enum ErrorNetwork: Error {
    case tryAgainLater
    case notFound
    case runtimeError(String)
}
