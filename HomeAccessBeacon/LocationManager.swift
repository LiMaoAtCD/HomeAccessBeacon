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

let iBeaconURLString = "http:192.168.11.126:8888/"

class LocationManager: CLLocationManager, CLLocationManagerDelegate {
    static let sharedManager = LocationManager()
    
    static let region = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: "E2C56DB5-DFFB-48D2-B060-D0F5A71096E0")!, major: 1, minor: 244, identifier: "com.Kaimenba.HomeAccess")
    
   
    private override init() {
        super.init()
        
    }
    
    func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
        let notification = UILocalNotification()
        
        notification.soundName = UILocalNotificationDefaultSoundName
        notification.alertBody = "您出门了，注意安全"
        
        
        UIApplication.sharedApplication().presentLocalNotificationNow(notification)
        
        
        Alamofire.request(.GET, iBeaconURLString, parameters: nil, encoding: ParameterEncoding.URL, headers: nil).responseString { (response) -> Void in
        }
    }
    
    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
        let notification = UILocalNotification()
        
        notification.soundName = UILocalNotificationDefaultSoundName
        notification.alertBody = "欢迎回家"
       
        UIApplication.sharedApplication().presentLocalNotificationNow(notification)
       
        Alamofire.request(.GET, iBeaconURLString, parameters: nil, encoding: ParameterEncoding.URL, headers: nil).responseString { (response) -> Void in
        }
        
        BlueToothManager.sharedManager
        
    }
    

    
    
}
