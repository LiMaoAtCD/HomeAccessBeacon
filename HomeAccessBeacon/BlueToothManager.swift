//
//  BlueToothManager.swift
//  HomeAccessBeacon
//
//  Created by AlienLi on 16/1/25.
//  Copyright © 2016年 MarcoLi. All rights reserved.
//

import UIKit
import CoreBluetooth
class BlueToothManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    static let sharedManager = BlueToothManager()
    
    var centralManager: CBCentralManager!
    var peripheral: CBPeripheral?
    
    private override init() {
        super.init()
    }
    
    func beginServices() {
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        centralManager = CBCentralManager(delegate: self, queue: queue, options: [CBCentralManagerOptionShowPowerAlertKey: true,CBCentralManagerOptionRestoreIdentifierKey: "com.Kaimenba.homeaccess"])
    }
    
    //MARK: CBCentralManagerDelegate
    
    func centralManagerDidUpdateState(central: CBCentralManager) {
        
        switch central.state {
        case .Unsupported:
            print("unsupported")
        case .Unknown:
            print("Unknown")
        case .Unauthorized:
            print("Unauthorized")
        case .Resetting:
            print("Resetting")
        case .PoweredOff:
            print("PoweredOff")
        case .PoweredOn:
            print("PoweredOn")
            
            print("蓝牙已开启，开始扫描外设")
//            if !central.isScanning {
//            central
                central.scanForPeripheralsWithServices(nil, options: nil)
//            }
        }
    }
    
    func centralManager(central: CBCentralManager, willRestoreState dict: [String : AnyObject]) {
//        CBCentralManagerRestoredStatePeripheralsKey
//        An array (an instance of NSArray) of CBPeripheral objects that contains all of the peripherals that were connected to the central manager (or had a connection pending) at the time the app was terminated by the system.
//            
//        When possible, all the information about a peripheral is restored, including any discovered services, characteristics, characteristic descriptors, and characteristic notification states.
//        
//        CBCentralManagerRestoredStateScanServicesKey
//        An array (an instance of NSArray) of service UUIDs (represented by CBUUID objects) that contains all the services the central manager was scanning for at the time the app was terminated by the system.
//        
//        CBCentralManagerRestoredStateScanOptionsKey
//        A dictionary (an instance of NSDictionary) that contains all of the peripheral scan options that were being used by the central manager at the time the app was terminated by the system.
        
        print("restore state: \(dict[CBCentralManagerRestoredStatePeripheralsKey])")
        
        let string = String(dict)
        let alert = UIAlertController(title: string, message: nil, preferredStyle: .Alert)
        
        let action = UIAlertAction(title: "ok", style: .Default, handler: nil)
        alert.addAction(action)
        
        UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        
        if let name = peripheral.name {
            if name == "pm_detector" {
                self.peripheral = peripheral
                self.peripheral?.delegate = BlueToothManager.sharedManager
                print("开始连接外设")
                central.connectPeripheral(self.peripheral!, options: nil)
                //停止扫描
                self.centralManager.stopScan()
            }
        }
    }
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {

        print("外设连接成功,开始发现外设服务")
        peripheral.discoverServices(nil)
        
    }
    
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        print("连接外设失败: \(error)")
    }
    
    
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        
        if let _ = error {
            print("发现外设服务出错：\(error)")
            centralManager.cancelPeripheralConnection(peripheral)
            
        } else {
            print("发现服务，开始发现服务特征值")
            
            if let services = peripheral.services {
                for service in services {
    
                    peripheral.discoverCharacteristics(nil, forService: service)
                }
            }
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        if let _ = error {
            print("发现服务特征值出错: \(error)")
            centralManager.cancelPeripheralConnection(peripheral)

        } else {
            
            if let characters = service.characteristics {
                for character in characters {
                    print("开始发现特征值描述")
//                    peripheral.discoverDescriptorsForCharacteristic(character)
//                    peripheral.readValueForCharacteristic(character)
                    
                    peripheral.setNotifyValue(true, forCharacteristic: character)
                }
            }
        }
    }
    
    
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        
        if let _ = error {
            print("发现服务特征值出错: \(error)")
            centralManager.cancelPeripheralConnection(peripheral)

        } else {
            
            let data = characteristic.value
            
            print("\(data)")
            
        }
        
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        if let _ = error {
            
        } else {
            
            let data = characteristic.value
            print("\(data)")

        }
    }
    
    
    func peripheral(peripheral: CBPeripheral, didDiscoverDescriptorsForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        if let _ = error {
            print("发现服务特征值描述符出错")
        } else {
            
            if let descriptors = characteristic.descriptors {
                for descriptor in descriptors {
                    peripheral.readValueForDescriptor(descriptor)
                }
            }
        }
        
        
    }
    
    
    
    
}
