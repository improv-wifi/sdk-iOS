//
//  DeviceStateTests.swift
//  Improv-iOSTests
//
//  Created by Bruno Pantaleão on 11/07/2024.
//

import XCTest
@testable import Improv_iOS

final class DeviceStateTests: XCTestCase {

    func test_DeviceState_Values() {
        XCTAssertEqual(DeviceState.authorizationRequired.rawValue, 0x01, "Expected authorizationRequired to have raw value 0x01")
        XCTAssertEqual(DeviceState.authorized.rawValue, 0x02, "Expected authorized to have raw value 0x02")
        XCTAssertEqual(DeviceState.provisioning.rawValue, 0x03, "Expected provisioning to have raw value 0x03")
        XCTAssertEqual(DeviceState.provisioned.rawValue, 0x04, "Expected provisioned to have raw value 0x04")
    }

    func test_DeviceState_Initialization() {
        XCTAssertEqual(DeviceState(rawValue: 0x01), .authorizationRequired, "Expected 0x01 to initialize to authorizationRequired")
        XCTAssertEqual(DeviceState(rawValue: 0x02), .authorized, "Expected 0x02 to initialize to authorized")
        XCTAssertEqual(DeviceState(rawValue: 0x03), .provisioning, "Expected 0x03 to initialize to provisioning")
        XCTAssertEqual(DeviceState(rawValue: 0x04), .provisioned, "Expected 0x04 to initialize to provisioned")
    }
}
