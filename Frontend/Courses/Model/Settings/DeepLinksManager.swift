//
//  DeepLinksManager.swift
//  Courses
//
//  Created by Руслан on 16.09.2024.
//

import Foundation
import UIKit
import Social


class DeepLinksManager {
    
    static var url = ""
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
    
    func fetchURL(url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return }
        
        DeepLinksManager.hosts = components.host
        
        if let pathComponents = components.path.split(separator: "/").compactMap({ String($0) }).last, let courseID = Int(pathComponents) {
            DeepLinksManager.courseID = courseID
            DeepLinksManager.isLink = true
        }
    }
    
    
    func openCourses(with window: UIWindow, isOpen: Bool = false) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        guard let vc = storyboard.instantiateViewController(identifier: "InfoCoursesViewController") as? InfoCoursesViewController else { return }
        guard let vcHome = storyboard.instantiateViewController(identifier: "UITabBarController") as? UITabBarController else { return }
        
        
        vc.course.id = DeepLinksManager.courseID!
        
        guard let navigationController = window.rootViewController as? UINavigationController else { return }
        if isOpen == false {
            navigationController.pushViewController(vcHome, animated: true)
        }
        navigationController.pushViewController(vc, animated: true)
        navigationController.navigationBar.isHidden = true
    }
    
    static func getLinkAboutCourse(idCourse: Int) -> URL {
        let link = URL(string: "https://stridecourses.ru/api/v1/deeplink/courses/\(idCourse)")!
        return link
    }
    
    static func openShareViewController(url: URL, _ viewController: UIViewController) {
        let items = [url]
        
        let shareController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        viewController.present(shareController, animated: true)
    }
    
}
