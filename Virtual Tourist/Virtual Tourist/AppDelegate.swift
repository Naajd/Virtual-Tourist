//
//  AppDelegate.swift
//  Virtual Tourist
//
//  Created by Najd  on 20/11/1440 AH.
//  Copyright © 1440 Udacity. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        DataController.shared.load()
        return true
    }
    
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        saveViewContext()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        saveViewContext()    }
    
    
    func saveViewContext() {
        try? DataController.shared.viewContext.save()
    }
    
    
    
    
}

