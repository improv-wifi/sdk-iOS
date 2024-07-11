//
//  RpcCommandTests.swift
//  Improv-iOSTests
//
//  Created by Bruno Pantaleão on 11/07/2024.
//

import XCTest
@testable import Improv_iOS

final class RpcCommandTests: XCTestCase {

    func test_RpcCommand_Values() {
        XCTAssertEqual(RpcCommand.sendWifi.rawValue, 1, "Expected sendWifi to have raw value 1")
        XCTAssertEqual(RpcCommand.identify.rawValue, 2, "Expected identify to have raw value 2")
    }

    func test_RpcCommand_Initialization() {
        XCTAssertEqual(RpcCommand(rawValue: 1), .sendWifi, "Expected 1 to initialize to sendWifi")
        XCTAssertEqual(RpcCommand(rawValue: 2), .identify, "Expected 2 to initialize to identify")
    }
}
