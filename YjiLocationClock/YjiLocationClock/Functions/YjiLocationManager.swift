//
//  YjiLocationManager.swift
//  YjiLocationClock
//
//  Created by 季云 on 16/4/1.
//  Copyright © 2016年 yji. All rights reserved.
//

import UIKit
import CoreLocation

let notificationGpsAuthorizaionGet = "notificationGpsAuthorizaionGet"
let notificationUpdateLocation = "notificationUpdateLocation"

class YjiLocationManager: NSObject, CLLocationManagerDelegate {
    
    var mLocationManager = CLLocationManager()
    let mNotificaionCenter = NotificationCenter.default
    var mIsBackgroundState = false
    var mErrMsg: String?
    
    // MARK: - Class Function
    // forever one
    class var sharedInstance: YjiLocationManager {
        struct Static {
            static let instance: YjiLocationManager = YjiLocationManager()
        }
        return Static.instance
    }
    
    override init() {
        super.init()
        
        mLocationManager.delegate = self
        mLocationManager.desiredAccuracy = kCLLocationAccuracyBest
        let iphoneVersion = UIDevice.current.systemVersion as NSString
        let nVersion = iphoneVersion.floatValue
        if  nVersion >= 8 {
            mLocationManager.requestAlwaysAuthorization()
        }
        if nVersion >= 9 {
            mLocationManager.allowsBackgroundLocationUpdates = true
        }
        
    }
    
    func startUpdateLocation() {
        mLocationManager.startUpdatingLocation()
    }
    
    func stopUpdateLocation() {
        mLocationManager.stopUpdatingLocation()
    }
    
    // user change the authorization
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.authorizedWhenInUse {
            mNotificaionCenter.post(name: Notification.Name(rawValue: notificationGpsAuthorizaionGet), object: nil)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        mNotificaionCenter.post(name: Notification.Name(rawValue: notificationUpdateLocation), object: nil, userInfo: ["newLocation" : location!])
    }

}
