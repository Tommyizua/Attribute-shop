//
//  AppDelegate.swift
//  Attribute
//
//  Created by Yaroslav on 19/11/15.
//  Copyright © 2015 Yaroslav Chyzh. All rights reserved.
//

import UIKit
import CoreData
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let tabBar = UITabBar.appearance()
        let navBar = UINavigationBar.appearance()
        
        let backgroundColor = UIColor.black
        let textColor = UIColor.orange
        
        tabBar.isTranslucent = false
        tabBar.barStyle = UIBarStyle.black
        tabBar.backgroundColor = backgroundColor
        tabBar.tintColor = textColor
        
        navBar.isTranslucent = false
        navBar.barStyle = UIBarStyle.black
        navBar.backgroundColor = backgroundColor
        navBar.tintColor = textColor
        
        if let font = UIFont(name: "Helvetica", size: 14) {
            
            navBar.titleTextAttributes = [NSFontAttributeName: font,
                                          NSForegroundColorAttributeName: textColor]
            
            UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName: font], for: UIControlState())
        }
        
        Fabric.with([Crashlytics.self])
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        DataManager.sharedInstance.saveContext()
    }
    
    
}

