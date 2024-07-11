//
//  Improv_iOSTests.swift
//  Improv-iOSTests
//
//  Created by Bruno Pantaleão on 03/07/2024.
//

import XCTest
import CoreBluetooth
@testable import Improv_iOS

class ImprovManagerTests: XCTestCase {

    private var sut: ImprovManager!
    private var mockBluetoothManager: MockBluetoothManager!

    override func setUp() async throws {
        try await super.setUp()

        mockBluetoothManager = MockBluetoothManager()

        sut = ImprovManager(
            bluetoothManager: mockBluetoothManager
        )
    }

    func test_scan_whileBluetoothOff_doesNothing() {
        mockBluetoothManager.state = .poweredOff
        sut.scan()

        XCTAssertFalse(mockBluetoothManager.scanCalled)
    }

    func test_scan_whileBluetoothOn_callsScan() {
        mockBluetoothManager.state = .poweredOn
        sut.scan()

        XCTAssertTrue(mockBluetoothManager.scanCalled)
        XCTAssertTrue(sut.scanInProgress)
    }

    func test_stopScan_callsStopScan() {
        sut.stopScan()

        XCTAssertTrue(mockBluetoothManager.stopScanCalled)
        XCTAssertFalse(sut.scanInProgress)
    }

    func test_identifyDevice_callIdentifyDevice() {
        sut.identifyDevice()

        XCTAssertTrue(mockBluetoothManager.identifyDeviceCalled)
    }

    func test_sendWifi_sendsWifi() {
        sut.sendWifi(ssid: "123", password: "123")

        XCTAssertEqual(mockBluetoothManager.lastSSID, "123")
        XCTAssertEqual(mockBluetoothManager.lastPassword, "123")
        XCTAssertTrue(mockBluetoothManager.sendWifiCalled)
    }

    func test_didUpdateBluetoothState_setsState() {
        sut.didUpdateBluetoohState(.poweredOff)

        XCTAssertEqual(sut.bluetoothState, .poweredOff)
    }

    func test_didUpdateDeviceState_setsState() {
        sut.didUpdateDeviceState(.authorized)

        XCTAssertEqual(sut.deviceState, .authorized)
    }

    func test_didUpdateErrorState_setsState() {
        sut.didUpdateErrorState(.notAuthorized)

        XCTAssertEqual(sut.errorState, .notAuthorized)
    }

    func test_didReceiveResult_setsResult() {
        sut.didReceiveResult(["abc"])

        XCTAssertEqual(sut.lastResult, ["abc"])
    }
}
