//
//  LocationManager.swift
//  HomeAccessBeacon
//
//  Created by AlienLi on 16/1/22.
//  Copyright © 2016年 MarcoLi. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
class LocationManager: CLLocationManager, CLLocationManagerDelegate {
    static let sharedManager = LocationManager()
    
    static let region = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: "E2C56DB5-DFFB-48D2-B060-D0F5A71096E0")!, major: 1, minor: 244, identifier: "com.Kaimenba.HomeAccess")
   
    private override init() {
        super.init()
        
        print("\(NSUserDefaults.standardUserDefaults().integerForKey("count"))")
    }
    
    func locationManager(manager: CLLocationManager, didDetermineState state: CLRegionState, forRegion region: CLRegion) {
        
        
        let notification = UILocalNotification()
        
        notification.soundName = UILocalNotificationDefaultSoundName
        if state == .Inside {
            notification.alertBody = "You're inside the region"
        } else if state == .Outside {
            notification.alertBody = "You're Outside the region"
            
        } else {
            return
        }
        
        UIApplication.sharedApplication().presentLocalNotificationNow(notification)
        
        let URLString = "http:/192.168.4.106:8888/"

        Alamofire.request(.GET, URLString, parameters: nil, encoding: ParameterEncoding.URL, headers: nil).responseString { (response) -> Void in
            print("\(response.description)")
        }
    }

    
    
}
