//
//  YjiMapTask.swift
//  YjiMap
//
//  Created by kiu-cts on 2016/02/09.
//  Copyright © 2016年 kiu-cts. All rights reserved.
//

import UIKit

class YjiMapTask: NSObject {
    
    let mBaseURLGeocode: NSString = "https://maps.googleapis.com/maps/api/geocode/json?"
    var mLookupAddressResults: NSDictionary!
    var mFetchedFormattedAddress: NSString!
    var mFetchedAddressLongitude: Double!
    var mFetchedAddressLatitude: Double!
    
    override init() {
        super.init()
    }
    
    func geocodeAddress(_ address: String!, withCompletionHandler completionHandler: @escaping ((_ status: String, _ success: Bool) -> Void)) {
        
        if let lookupAddress = address {
            let geocodeURLString = mBaseURLGeocode.appending("address=") + lookupAddress.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)! // swift encoding
            let geocodeURL = URL.init(string: geocodeURLString)
            
            DispatchQueue.main.async(execute: { () -> Void in
                let geocodingResultsData = try? Data(contentsOf: geocodeURL!)
                var dictionary:NSDictionary?
                do {
                   dictionary =  try JSONSerialization.jsonObject(with: geocodingResultsData!, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
                } catch {
                    print(error)
                    completionHandler("", false)
                }
                
                let status = dictionary!["status"] as! String
                if status == "OK" {
                    let allResults = dictionary!["results"] as! NSArray
                    self.mLookupAddressResults = allResults[0] as! NSDictionary
                    // Keep the most important values.
                    self.mFetchedFormattedAddress = self.mLookupAddressResults["formatted_address"] as! NSString
                    let geometry = self.mLookupAddressResults["geometry"] as! NSDictionary
                    self.mFetchedAddressLongitude = ((geometry["location"] as! NSDictionary)["lng"] as! NSNumber).doubleValue
                    self.mFetchedAddressLatitude = ((geometry["location"] as! NSDictionary)["lat"] as! NSNumber).doubleValue
                    completionHandler(status, true)
                }
                else {
                    completionHandler(status, false)
                }
            })
        }
        
    }
    

}
