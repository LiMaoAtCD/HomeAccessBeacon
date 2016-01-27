//
//  BlueToothCenter.swift
//  HomeAccessBeacon
//
//  Created by AlienLi on 16/1/27.
//  Copyright © 2016年 MarcoLi. All rights reserved.
//

import UIKit
import CoreBluetooth


typealias updateHandler = (String?) -> Void

class BlueToothCenter: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    static let defaultCenter = BlueToothCenter()
    var centralManager: CBCentralManager!
    var peripheral: CBPeripheral?
    
    //MARK:
    private override init() {
        super.init()
    }
    //MARK: 启动蓝牙服务
    func startBlueToothServices() {
        
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        centralManager = CBCentralManager(delegate: self, queue: queue, options: [CBCentralManagerOptionShowPowerAlertKey: true])
    }
    //MARK: 关闭蓝牙服务

    func stopBlueToothServices() {
        
        guard let peripheral_temp = peripheral else{
            return
        }
        guard let services = peripheral_temp.services else{
            return
        }
        for service in services {
            guard let characteristics = service.characteristics else {
                return
            }
            for characteristic in characteristics {
                if characteristic.isNotifying {
                    peripheral_temp.setNotifyValue(false, forCharacteristic: characteristic)
                }
            }
        }
        defer{
            centralManager.cancelPeripheralConnection(peripheral_temp)
        }
    }
    
    //MARK: CBCentralManagerDelegate
    
    func centralManagerDidUpdateState(central: CBCentralManager) {
        
        guard central.state == .PoweredOn else{
            return
        }
        
        central.scanForPeripheralsWithServices(nil, options: nil)
    }
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        
        if let name = peripheral.name {
            //过滤要扫描的设备
            if name.hasPrefix("AlienLi") {
                
                
                self.peripheral = peripheral
                self.peripheral?.delegate = BlueToothCenter.defaultCenter
                print("开始连接外设")
                central.connectPeripheral(self.peripheral!, options: nil)
            }
        }
    }

    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        //停止扫描
        self.centralManager.stopScan()
        //发现服务
        peripheral.discoverServices([CBUUID(string: "FFF0")])
    }
    
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        print("连接外设失败: \(error?.localizedDescription)")
    }
    
    
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        print("已断开连接: \(error?.localizedDescription)")
        
        if let _ = error {
            centralManager.cancelPeripheralConnection(peripheral)
        } else {
            print("已断开连接")
        }

    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        
        if let _ = error {
            print("发现外设服务出错：\(error?.localizedDescription)")
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
                    peripheral.setNotifyValue(true, forCharacteristic: character)
                }
            }
        }
    }
    
    
    var string: String?
    var handler: updateHandler?
    
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        
        if let _ = error {
            print("发现服务特征值出错: \(error)")
            centralManager.cancelPeripheralConnection(peripheral)
        } else {
            
            let data = characteristic.value
            string =  NSString(data: data!, encoding: NSUTF8StringEncoding) as? String
            
            if let _ = handler {
                handler!(string)
            }
        }
    }
    
    
    func peripheral(peripheral: CBPeripheral, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        if let _ = error {
            print("\(error?.localizedDescription)")
        } else {
            
        }
    }
    
//    
//    func peripheral(peripheral: CBPeripheral, didDiscoverDescriptorsForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
//        if let _ = error {
//            print("发现服务特征值描述符出错")
//        } else {
//            
//            if let descriptors = characteristic.descriptors {
//                for descriptor in descriptors {
//                    peripheral.readValueForDescriptor(descriptor)
//                }
//            }
//        }
//    }
}
