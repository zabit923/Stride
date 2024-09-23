//
//  DeepLinksManager.swift
//  Courses
//
//  Created by Руслан on 16.09.2024.
//

import Foundation
import UIKit

class DeepLinksManager {
    
    static var hosts: String?
    static var courseID: Int?
    
    func fetchURL(connectionOptions: UIScene.ConnectionOptions) {
        guard let url = connectionOptions.urlContexts.first?.url else { return }
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let hosts = components.host,
              let courseID = components.queryItems!.first(where: { $0.name == "id" })?.value  else {return}
        
        guard let id = Int(courseID) else {return}
        DeepLinksManager.hosts = hosts
        DeepLinksManager.courseID = id
    }
    
    func openCourses(with viewController: UIViewController) {
        viewController.performSegue(withIdentifier: "infoCourses", sender: self)
    }
    
}
