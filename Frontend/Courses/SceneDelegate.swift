//
//  SceneDelegate.swift
//  Courses
//
//  Created by Руслан on 10.06.2024.
//

import UIKit
import ScreenProtectorKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var protectScreen = ProtectScreen()
    
    
    func scene(_ scene: UIScene,willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        DeepLinksManager().fetchURL(connectionOptions: connectionOptions)
        if DeepLinksManager.isLink {
            DeepLinksManager().openCourses(with: window!)
        }
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let url = URLContexts.first?.url {
            DeepLinksManager().fetchURL(url: url)
            if DeepLinksManager.isLink {
                DeepLinksManager().openCourses(with: window!, isOpen: true)
            }
        }
    }
                                        

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
    }


    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}
