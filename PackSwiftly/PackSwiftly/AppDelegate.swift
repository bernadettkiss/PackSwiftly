//
//  AppDelegate.swift
//  PackSwiftly
//
//  Created by Bernadett Kiss on 8/27/18.
//  Copyright © 2018 Bernadett Kiss. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    let dataController = DataController(modelName: "PackSwiftly")
    public var unitOfTemperatureIsCelsius = true
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        if !UserDefaults.standard.bool(forKey: "unitOfTemperatureIsCelsius") {
            unitOfTemperatureIsCelsius = false
        }
        
        let navigationController = window?.rootViewController as! UINavigationController
        let tripsViewController = navigationController.topViewController as! TripsViewController
        tripsViewController.dataController = dataController
        
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        dataController.saveViewContext()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        dataController.saveViewContext()
    }
}
