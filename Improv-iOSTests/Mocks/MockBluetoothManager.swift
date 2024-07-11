//
//  MockBluetoothManagerProtocol.swift
//  Improv-iOSTests
//
//  Created by Bruno Pantaleão on 11/07/2024.
//

import Foundation
import CoreBluetooth
@testable import Improv_iOS

class MockBluetoothManager: BluetoothManagerProtocol {
    weak var delegate: BluetoothManagerDelegate?
    var state: CBManagerState = .unknown

    var scanCalled = false
    var stopScanCalled = false
    var connectToDeviceCalled = false
    var identifyDeviceCalled = false
    var sendWifiCalled = false

    var lastPeripheral: CBPeripheral?
    var lastSSID: String?
    var lastPassword: String?

    func scan() {
        scanCalled = true
    }

    func stopScan() {
        stopScanCalled = true
    }

    func connectToDevice(_ peripheral: CBPeripheral) {
        connectToDeviceCalled = true
        lastPeripheral = peripheral
    }

    func identifyDevice() {
        identifyDeviceCalled = true
    }

    func sendWifi(ssid: String, password: String) {
        sendWifiCalled = true
        lastSSID = ssid
        lastPassword = password
    }
}
