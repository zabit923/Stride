//
//  Comments.swift
//  Courses
//
//  Created by Руслан on 18.08.2024.
//

import Foundation
import Alamofire
import SwiftyJSON

class Comments {
    
    func getComments(courseID: Int) async throws -> [Reviews] {
        let url = Constants.url + "api/v1/comments/\(courseID)/"
        let headers: HTTPHeaders = ["Authorization": "Bearer \(User.info.token)"]
        let value = try await AF.request(url, headers: headers).serializingData().value
        let json = JSON(value)
        var comments = [Reviews]()
        
        let results = json.arrayValue
        guard results.isEmpty == false else {return []}
        
        for x in 0...results.count - 1 {
            let id = json[x]["id"].intValue
            let author = "\(json[x]["author"]["first_name"].stringValue) \(json[x]["author"]["last_name"].stringValue)"
            let text = json[x]["text"].stringValue
            let date = json[x]["created_at"].stringValue
            let datePart = date.replacingOccurrences(of: "T.*", with: "", options: .regularExpression)
            let courseID = json[x]["course"].intValue
            comments.append(Reviews(id: id, author: author, text: text, date: datePart, courseID: courseID))
        }
        return comments
    }
    
    func addComment(idCourse: Int, rating: Int, text: String) async throws {
        let url = Constants.url + "/api/v1/comments/"
        let headers: HTTPHeaders = ["Authorization": "Bearer \(User.info.token)"]
        let parameters: Parameters = [
            "course": idCourse,
            "text": text
        ]
        let value = try await AF.request(url,method: .post,parameters: parameters, headers: headers).serializingData().value
        let json = JSON(value)
        print(json)
        try await addRating(rating: rating, idCourse: idCourse)
    }
    
    private func addRating(rating: Int, idCourse: Int) async throws {
        let url = Constants.url + "/api/v1/rating/"
        let headers: HTTPHeaders = ["Authorization": "Bearer \(User.info.token)"]
        let parameters: Parameters = [
            "course": idCourse,
            "rating": rating
        ]
        let value = try await AF.request(url, method: .post,parameters: parameters, headers: headers).serializingData().value
        let json = JSON(value)
        print(json)
    }
    
}
