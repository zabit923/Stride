//
//  RefreshControll.swift
//  Courses
//
//  Created by Руслан on 28.10.2024.
//

import Foundation
import UIKit


class RefreshControll {
    var refreshControl = UIRefreshControl()
    
    func refreshSettings(scrollView:UIScrollView) {
        refreshControl.tintColor = UIColor.blueMain
        scrollView.addSubview(refreshControl)
    }
    
    
}
