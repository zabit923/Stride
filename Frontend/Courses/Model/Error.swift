//
//  Error.swift
//  Courses
//
//  Created by Руслан on 23.06.2024.
//

import Foundation
import Network

enum ErrorNetwork: Error {
    case tryAgainLater
    case notFound
    case runtimeError(String)
}

class Network {
    
    func checkNetwork() -> Bool {
            let monitor = NWPathMonitor()
            var isInternetAvailable = false
            
            monitor.pathUpdateHandler = { path in
                if path.status == .satisfied {
                    isInternetAvailable = true
                } else {
                    isInternetAvailable = false
                }
                monitor.cancel()
            }
            
            monitor.start(queue: .global())
            
            return isInternetAvailable
        }

}
