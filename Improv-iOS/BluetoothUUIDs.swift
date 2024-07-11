//
//  BluetoothUUIDs.swift
//  Improv-iOS
//
//  Created by Bruno Pantaleão on 11/07/2024.
//

import CoreBluetooth

enum BluetoothUUIDs {
    static let serviceProvision = CBUUID(string: "00467768-6228-2272-4663-277478268000")
    static let charCurrentState = CBUUID(string: "00467768-6228-2272-4663-277478268001")
    static let charErrorState = CBUUID(string: "00467768-6228-2272-4663-277478268002")
    static let charRpc = CBUUID(string: "00467768-6228-2272-4663-277478268003")
    static let charRpcResult = CBUUID(string: "00467768-6228-2272-4663-277478268004")
}
