//
//  YjiComFuncs.swift
//  YjiLocationClock
//
//  Created by 季云 on 16/3/30.
//  Copyright © 2016年 yji. All rights reserved.
//

import UIKit
import GoogleMaps
import UserNotifications

class YjiComFuncs: NSObject {
    
    class func getMeterFrom(_ oldLocation: CLLocation, newLocation:CLLocation) -> CLLocationDistance {        
        let meters: CLLocationDistance = newLocation.distance(from: oldLocation)
        return meters
    }
    
    class func getScreenSize() -> CGSize {
        let screenSize = UIScreen.main.bounds.size
        return screenSize
    }
    
    class func getScreenWidth() -> CGFloat {
        let width = UIScreen.main.bounds.width
        return width
    }
    
    class func getScreenHeight() -> CGFloat {
        let height = UIScreen.main.bounds.height
        return height
    }
    
    // MARK: - native notification
    class func sendNativeNotification() {
        DispatchQueue.main.async {
            if #available(iOS 10.0, *) {
                let content = UNMutableNotificationContent()
                content.title = "ご注意ください"
                content.body = "すぐに到着しますよ！！！"
                content.sound = UNNotificationSound.default()
                content.badge = 1
                let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 5, repeats: false)
                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                let center = UNUserNotificationCenter.current()
                center.add(request, withCompletionHandler: { (error) in
                    if error == nil {
                        print("add NotificationRequest succeeded")
                    }
                })
            } else {
                // Fallback on earlier versions
                let noti = UILocalNotification()
                noti.fireDate = Date()
                noti.soundName = UILocalNotificationDefaultSoundName
                noti.alertBody = "すぐに到着しますよ"
                noti.applicationIconBadgeNumber = 1
                UIApplication.shared.scheduleLocalNotification(noti)
            }
        }
    }
    
}
