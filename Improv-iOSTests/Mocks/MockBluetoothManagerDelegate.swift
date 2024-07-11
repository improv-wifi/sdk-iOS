//
//  MockBluetoothManagerDelegate.swift
//  Improv-iOSTests
//
//  Created by Bruno Pantaleão on 11/07/2024.
//

import Foundation
import CoreBluetooth
@testable import Improv_iOS

final class MockBluetoothManagerDelegate: BluetoothManagerDelegate {
    var didUpdateBluetoothStateCalled = false
    var didUpdateDeviceStateCalled = false
    var didUpdateErrorStateCalled = false
    var didFindNewDeviceCalled = false
    var didConnectCalled = false
    var didDisconnectCalled = false
    var didReceiveResultCalled = false

    var lastBluetoothState: CBManagerState?
    var lastDeviceState: DeviceState?
    var lastErrorState: ErrorState?
    var lastPeripheral: CBPeripheral?
    var lastResult: [String]?

    func didUpdateBluetoohState(_ state: CBManagerState) {
        didUpdateBluetoothStateCalled = true
        lastBluetoothState = state
    }

    func didUpdateDeviceState(_ state: DeviceState?) {
        didUpdateDeviceStateCalled = true
        lastDeviceState = state
    }

    func didUpdateErrorState(_ state: ErrorState?) {
        didUpdateErrorStateCalled = true
        lastErrorState = state
    }

    func didFindNewDevice(peripheral: CBPeripheral) {
        didFindNewDeviceCalled = true
        lastPeripheral = peripheral
    }

    func didConnect(peripheral: CBPeripheral) {
        didConnectCalled = true
        lastPeripheral = peripheral
    }

    func didDisconnect(peripheral: CBPeripheral) {
        didDisconnectCalled = true
        lastPeripheral = peripheral
    }

    func didReceiveResult(_ result: [String]?) {
        didReceiveResultCalled = true
        lastResult = result
    }
}
