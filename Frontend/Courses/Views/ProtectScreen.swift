//
//  ProtectScreen.swift
//  Courses
//
//  Created by Руслан on 20.11.2024.
//

import Foundation
import UIKit
import ScreenProtectorKit

class ProtectScreen {
    
    static var currentVc: UIViewController = StartViewController() {
        didSet {
            ProtectScreen().updateProtect()
        }
    }
    static var isRecording = false
    var window: UIWindow!
    private lazy var screenProtectorKit = { return ScreenProtectorKit(window: window) }()

    func updateProtect() {
        print(ProtectScreen.isRecording, ProtectScreen.currentVc)
        if (ProtectScreen.currentVc is ModulesCourseViewController || ProtectScreen.currentVc is CourseTextViewController) && ProtectScreen.isRecording == true {
            self.screenProtectorKit.enabledBlurScreen()
        }
    }
    
    func protectFromScreenRecording() {
        UIScreen.main.observe(\UIScreen.isCaptured, options: [.new]) { [weak self] screen, change in
            
            let isRecording = change.newValue ?? false
            if isRecording {
                self?.screenProtectorKit.enabledBlurScreen()
            } else {
                self?.screenProtectorKit.disableBlurScreen()
            }
        }
    }
    
    func protectOn() {
        screenProtectorKit.configurePreventionScreenshot()
        screenProtectorKit.screenshotObserver {
            
        }
        screenProtectorKit.screenRecordObserver { isRecording in
            ProtectScreen.isRecording = isRecording
            if isRecording && (ProtectScreen.currentVc is ModulesCourseViewController || ProtectScreen.currentVc is CourseTextViewController) {
                self.screenProtectorKit.enabledBlurScreen()
            }else {
                self.screenProtectorKit.disableBlurScreen()
            }
        }
    }
    
    func protectOff() {
        screenProtectorKit.removeAllObserver()
    }
}
