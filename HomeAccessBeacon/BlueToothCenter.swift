//
//  BlueToothCenter.swift
//  HomeAccessBeacon
//
//  Created by AlienLi on 16/1/27.
//  Copyright © 2016年 MarcoLi. All rights reserved.
//

import UIKit
import CoreBluetooth


typealias updateHandler = ([Double]?) -> Void

class BlueToothCenter: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    static let defaultCenter = BlueToothCenter()
    var centralManager: CBCentralManager!
    var peripheral: CBPeripheral? //持有外设实力
    var sid: UInt8 = 0              //蓝牙协议
    var character:CBCharacteristic? //持有特征值
    var items:[Double]? = Array<Double>.init(count: 0, repeatedValue: 12)
    var receiveSign: UInt8 = 0
    var timer: NSTimer!
    
    
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
        
        self.timer.invalidate()
        self.timer = nil
        
    }
    
    //MARK: 扫描
    
    func centralManagerDidUpdateState(central: CBCentralManager) {
        
        guard central.state == .PoweredOn else{
            return
        }
        
        central.scanForPeripheralsWithServices(nil, options: nil)
    }
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        
        if let name = peripheral.name {
            //过滤要扫描的设备
            if name.hasSuffix("xxdust_detector") {
    
                self.peripheral = peripheral
                self.peripheral?.delegate = BlueToothCenter.defaultCenter
                print("开始连接外设")
                central.connectPeripheral(self.peripheral!, options: nil)
            }
        }
    }

    //MARK: 连接

    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        self.centralManager.stopScan()
        peripheral.discoverServices([
            CBUUID(string: "6E400001-B5A3-F393-E0A9-E50E24DCCA9E"),
            CBUUID(string: "6E400002-B5A3-F393-E0A9-E50E24DCCA9E"),
            CBUUID(string: "6E400003-B5A3-F393-E0A9-E50E24DCCA9E")])
    }
    
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        print("连接外设失败: \(error?.localizedDescription)")
    }
    
    
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        print("已断开连接出错: \(error?.localizedDescription)")
        
        if let _ = error {
            centralManager.cancelPeripheralConnection(peripheral)
        } else {
            print("已断开外设连接")
        }
    }
    
    //MARK: 服务

    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        
        if let _ = error {
            print("发现外设服务出错：\(error?.localizedDescription)")
            centralManager.cancelPeripheralConnection(peripheral)
        } else {
            if let services = peripheral.services {
                for service in services {
                    peripheral.discoverCharacteristics(nil, forService: service)
                }
            }
        }
    }
    
    //MARK: 特征值

    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        if let _ = error {
            print("发现服务特征值出错: \(error)")
            centralManager.cancelPeripheralConnection(peripheral)
            
        } else {

            if let characters = service.characteristics {
                for character in characters {
                        if character.properties.contains(CBCharacteristicProperties.Notify) {
                            peripheral.setNotifyValue(true, forCharacteristic: character)
                        }
                    if character.UUID == CBUUID(string: "6E400002-B5A3-F393-E0A9-E50E24DCCA9E") {
                        self.character = character
                    }
                    self.fetchPmData()
                }
            }
        }
    }
    
    func fetchPmData() {
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.timer = NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: "fetchData", userInfo: nil, repeats: true)
            
//            NSRunLoop.currentRunLoop().addTimer(self.timer, forMode: NSDefaultRunLoopMode)
//            NSRunLoop.currentRunLoop().runUntilDate(NSDate.distantFuture())
        }
//        timer.fire()
    }
    
    func fetchData() {
        guard let _ = character else{
            return
        }
        guard let _ = peripheral else {
            return
        }
        //版本 + 命令 + sid + 数据长度 + 数据
        let  data = NSData(bytes: [0x01, 0x02, getSid(),0x00] as [UInt8], length: 4)
        
        peripheral!.writeValue(data, forCharacteristic: character!, type: CBCharacteristicWriteType.WithoutResponse)
    }
    
    
    
    func adjustTime(timeStamp: Int) {
        
        guard let _ = character else{
            return
        }
        
        guard let _ = peripheral else {
            return
        }
        //版本 + 命令 + sid + 数据长度 + 数据
        let  data = NSData(bytes: [0x01, 0x01, getSid(),0x04,0x00,0x00,0x00,0x00] as [UInt8], length: 8)
        
        peripheral!.writeValue(data, forCharacteristic: character!, type: CBCharacteristicWriteType.WithoutResponse)
    }
    
    func getSid() -> UInt8 {
        
        sid++
        let s = sid & 0xff
        
        return s
    }
    
    var string: String?
    var handler: updateHandler?
    
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        
        if let _ = error {
            centralManager.cancelPeripheralConnection(peripheral)
        } else {
            let data = characteristic.value
            var byteArray = [UInt8](count: data!.length, repeatedValue: 0x0)
            data!.getBytes(&byteArray, length:data!.length)
//            print(byteArray)
            //监测标志位
            let signData = byteArray[1]
            if signData == 0x13 {
                
                let pm1_0_USA = Double(Int(byteArray[5]) * 0xff + Int(byteArray[4]))
                let pm2_5_USA = Double(Int(byteArray[7]) * 0xff + Int(byteArray[6]))
                let pm10_0_USA = Double(Int(byteArray[9]) * 0xff + Int(byteArray[8]))
                let pm1_0_CN = Double(Int(byteArray[11]) * 0xff + Int(byteArray[10]))
                let pm2_5_CN = Double(Int(byteArray[13]) * 0xff + Int(byteArray[12]))
                let pm10_0_CN = Double(Int(byteArray[15]) * 0xff + Int(byteArray[14]))
//
                items?.appendContentsOf([pm1_0_USA, pm2_5_USA, pm10_0_USA, pm1_0_CN, pm2_5_CN, pm10_0_CN])
                
                receiveSign++
                
                
            } else if signData == 0x14 {
            
                let um0_3 = Double(Int(byteArray[5]) * 0xff + Int(byteArray[4]))
                let um0_5 = Double(Int(byteArray[7]) * 0xff + Int(byteArray[6]))
                let um1_0 = Double(Int(byteArray[9]) * 0xff + Int(byteArray[8]))
                let um2_5 = Double(Int(byteArray[11]) * 0xff + Int(byteArray[10]))
                let um5_0 = Double(Int(byteArray[13]) * 0xff + Int(byteArray[12]))
                let um10_0 = Double(Int(byteArray[15]) * 0xff + Int(byteArray[14]))
                //
                items?.appendContentsOf([um0_3, um0_5, um1_0, um2_5, um5_0, um10_0])

                receiveSign++
            }
            
            if receiveSign == 2 {
                
                guard let handleData = handler else {
                    return
                }
                
                guard let _ = items else {
                    return
                }
                
                handleData(items!)
                
                items = Array<Double>.init(count: 0, repeatedValue: 12)
                receiveSign = 0
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
