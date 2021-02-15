//
//  BLEPeripheral.swift
//  Mentalist
//
//  Created by SOWA KILLIAN on 15/02/2021.
//

import Foundation
import CoreBluetooth

class BluetoothPeripheral {
    var coreBluetoothItem: CBPeripheral
    var name: String
    
    enum CodingKeys: String, CodingKey {
        case coreBluetoothItem
        case name
    }

    init(coreBluetoothItem: CBPeripheral, name: String) {
        self.coreBluetoothItem = coreBluetoothItem
        self.name = name
    }
}
