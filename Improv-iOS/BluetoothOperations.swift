//
//  BluetoothOperations.swift
//  Improv-iOS
//
//  Created by Bruno Pantaleão on 03/07/2024.
//

import Foundation
import CoreBluetooth

protocol BleOperationType { }

struct Connect: BleOperationType {
    let device: CBPeripheral
}

struct Disconnect: BleOperationType { }

struct CharacteristicWrite: BleOperationType {
    let char: CBCharacteristic
    let data: Data
}

struct CharacteristicRead: BleOperationType {
    let char: CBCharacteristic
}

struct DescriptorWrite: BleOperationType {
    let desc: CBDescriptor
    let data: Data
}
