//
//  AppDelegate.swift
//  YjiLocationClock
//
//  Created by 季云 on 16/3/27.
//  Copyright © 2016年 yji. All rights reserved.
//

import UIKit
import GoogleMaps
import AVFoundation
import UserNotifications
import GooglePlaces

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // register local notification
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().requestAuthorization(options:[.alert, .sound]) { (granted, error) in
                if granted {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        } else {
            // Fallback on earlier versions
            let notificationSettings = UIUserNotificationSettings(types: [.alert, .sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(notificationSettings)
        }
        GMSPlacesClient.provideAPIKey("AIzaSyDmwy8k-2l1eA8U7Rxzu3qsn0_3yIihl08")
        GMSServices.provideAPIKey("AIzaSyBPcw_1fepJI5xVVE1l7mCzxmoZ8Ebox_8")
        UIApplication.shared.statusBarStyle = .lightContent
        let hasLogin = UserDefaults.standard.object(forKey: "login")
        var nvc: UINavigationController? = nil
        if hasLogin == nil || hasLogin as! Bool == false {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let firstVc = storyboard.instantiateInitialViewController()
            nvc = UINavigationController(rootViewController: firstVc!)
        } else {
            let firstVc = YjiGMapSearchVc()
            nvc = UINavigationController(rootViewController: firstVc)
        }
        self.window?.rootViewController = nvc
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        YjiLocationManager.sharedInstance.mIsBackgroundState = true
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        YjiLocationManager.sharedInstance.mIsBackgroundState = false
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

