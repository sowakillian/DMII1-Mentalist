//
//  BLEManager.swift
//  Mentalist
//
//  Created by SOWA KILLIAN on 15/02/2021.
//

import Foundation
import CoreBluetooth

class BLEManager: NSObject {
    static let instance = BLEManager()
    
    var isBLEEnabled = false
    var isScanning = false
    let authCBUUID = CBUUID(string: "499D456C-8691-4D00-87E2-8A34FB7551A3")
    let writeCBUUID = CBUUID(string: "39558C62-0EF9-472F-8E38-01F70A07AC55")
    let readCBUUID = CBUUID(string: "B2DBA4DB-6C7B-4649-A66D-2308B7BB835F")
    let mapReadCBUUID = CBUUID(string: "9DE0451B-4F87-4677-9FC4-2C81BDF27822")
    var centralManager: CBCentralManager?
    var connectedPeripherals = [CBPeripheral]()
    var readyPeripherals = [CBPeripheral]()
    
    var scanCallback: ((CBPeripheral, String) -> ())?
    var connectCallback: ((CBPeripheral) -> ())?
    var disconnectCallback: ((CBPeripheral) -> ())?
    var didFinishDiscoveryCallback: ((CBPeripheral) -> ())?
    var globalDisconnectCallback: ((CBPeripheral) -> ())?
    var sendDataCallback: ((String?) -> ())?
    var readDataCallback: ((String?) -> ())?
    var readMapDataCallback: ((String?) -> ())?
    var messageReceivedCallback:((Data?)->())?
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func clear() {
        connectedPeripherals = []
        readyPeripherals = []
    }
    
    func scan(callback: @escaping (CBPeripheral, String) -> ()) {
        isScanning = true
        scanCallback = callback
        centralManager?.scanForPeripherals(withServices: [], options: nil)
    }
    
    func stopScan() {
        isScanning = false
        centralManager?.stopScan()
    }
    
    func listenForMessages(callback:@escaping(Data?)->()) {
        messageReceivedCallback = callback
    }
    
    func connectPeripheral(_ periph: CBPeripheral, callback: @escaping (CBPeripheral) -> ()) {
        connectCallback = callback
        centralManager?.connect(periph, options: nil)
    }
    
    func disconnectPeripheral(_ periph: CBPeripheral, callback: @escaping (CBPeripheral) -> ()) {
        disconnectCallback = callback
        centralManager?.cancelPeripheralConnection(periph)
    }
    
    func didDisconnectPeripheral(callback: @escaping (CBPeripheral) -> ()) {
        disconnectCallback = callback
        globalDisconnectCallback = callback
    }
    
    func discoverPeripheral(_ periph: CBPeripheral, callback: @escaping (CBPeripheral) -> ()) {
        didFinishDiscoveryCallback = callback
        periph.delegate = self
        periph.discoverServices(nil)
        
    }
    
    func getCharForUUID(_ uuid: CBUUID, forperipheral peripheral: CBPeripheral) -> CBCharacteristic? {
        if let services = peripheral.services {
            for service in services {
                if let characteristics = service.characteristics {
                    for char in characteristics {
                        if char.uuid == uuid {
                            return char
                        }
                    }
                }
            }
        }
        return nil
    }
    
    func sendData(data: Data, callback: @escaping (String?) -> ()) {
        sendDataCallback = callback
        for periph in readyPeripherals {
            if let char = BLEManager.instance.getCharForUUID(writeCBUUID, forperipheral: periph) {
                periph.writeValue(data, for: char, type: CBCharacteristicWriteType.withResponse)
            }
        }
    }
    
    func readData(callback: @escaping (String?) -> ()) {
        readDataCallback = callback
        for periph in readyPeripherals {
            if let char = BLEManager.instance.getCharForUUID(readCBUUID, forperipheral: periph) {
                periph.readValue(for: char)
            }
        }
    }
    
    func readMapData(callback: @escaping (String?) -> ()) {
        readMapDataCallback = callback
        for periph in readyPeripherals {
            if let char = BLEManager.instance.getCharForUUID(mapReadCBUUID, forperipheral: periph) {
                periph.readValue(for: char)
            }
        }
    }
    
}

extension BLEManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services {
            for service in services {
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let services = peripheral.services {
            let count = services.filter { $0.characteristics == nil }.count
            if count == 0 {
                for s in services {
                    for c in s.characteristics! {
                            peripheral.setNotifyValue(true, for: c)
                    }
                }
                readyPeripherals.append(peripheral)
                didFinishDiscoveryCallback?(peripheral)
            }
        }
    }
}

extension BLEManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            isBLEEnabled = true
        } else {
            isBLEEnabled = false
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let localName = advertisementData[CBAdvertisementDataLocalNameKey] as? String
        if let name = localName {
            scanCallback?(peripheral, name)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if !connectedPeripherals.contains(peripheral) {
            connectedPeripherals.append(peripheral)
            connectCallback?(peripheral)
        }
    }
        
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        connectedPeripherals.removeAll { $0 == peripheral }
        readyPeripherals.removeAll { $0 == peripheral }
        disconnectCallback?(peripheral)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print("UPDATE!!!")
        print("char = \(characteristic.value)")
        
        messageReceivedCallback?(characteristic.value)
        if let value = characteristic.value {
            print("value")
            print("**ohhhh value mamene")
            readDataCallback?(String(decoding: value, as: UTF8.self))
            readMapDataCallback?(String(decoding: value, as: UTF8.self))
        } else {
            print("naze")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        sendDataCallback?(peripheral.name)
    }
}
