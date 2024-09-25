//
//  DeepLinksManager.swift
//  Courses
//
//  Created by Руслан on 16.09.2024.
//

import Foundation
import UIKit

class DeepLinksManager {
    
    static var isLink = false
    static var hosts: String?
    static var courseID: Int?
    
    func fetchURL(connectionOptions: UIScene.ConnectionOptions) {
        guard let url = connectionOptions.urlContexts.first?.url else { return }
        
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return }
        
        DeepLinksManager.hosts = components.host
        
        if let pathComponents = components.path.split(separator: "/").compactMap({ String($0) }).last, let courseID = Int(pathComponents) {
            DeepLinksManager.courseID = courseID
            DeepLinksManager.isLink = true
        }
    }
    
    
    func openCourses(with window: UIWindow) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        guard let vc = storyboard.instantiateViewController(identifier: "InfoCoursesViewController") as? InfoCoursesViewController else { return }
        
        vc.course.id = DeepLinksManager.courseID!
        
        guard let navigationController = window.rootViewController as? UINavigationController else { return }
        
        navigationController.pushViewController(vc, animated: true)
        //        viewController.performSegue(withIdentifier: "deepLink", sender: self)
    }
    
    
}
