//
//  ErrorStateTests.swift
//  Improv-iOSTests
//
//  Created by Bruno Pantaleão on 11/07/2024.
//

import XCTest
@testable import Improv_iOS

final class ErrorStateTests: XCTestCase {

    func test_ErrorState_Values() {
        XCTAssertEqual(ErrorState.noError.rawValue, 0x00, "Expected noError to have raw value 0x00")
        XCTAssertEqual(ErrorState.invalidRPCPacket.rawValue, 0x01, "Expected invalidRPCPacket to have raw value 0x01")
        XCTAssertEqual(ErrorState.unknownCommand.rawValue, 0x02, "Expected unknownCommand to have raw value 0x02")
        XCTAssertEqual(ErrorState.unableToConnect.rawValue, 0x03, "Expected unableToConnect to have raw value 0x03")
        XCTAssertEqual(ErrorState.notAuthorized.rawValue, 0x04, "Expected notAuthorized to have raw value 0x04")
        XCTAssertEqual(ErrorState.unknown.rawValue, 0xff, "Expected unknown to have raw value 0xff")
    }

    func test_ErrorState_Initialization() {
        XCTAssertEqual(ErrorState(rawValue: 0x00), .noError, "Expected 0x00 to initialize to noError")
        XCTAssertEqual(ErrorState(rawValue: 0x01), .invalidRPCPacket, "Expected 0x01 to initialize to invalidRPCPacket")
        XCTAssertEqual(ErrorState(rawValue: 0x02), .unknownCommand, "Expected 0x02 to initialize to unknownCommand")
        XCTAssertEqual(ErrorState(rawValue: 0x03), .unableToConnect, "Expected 0x03 to initialize to unableToConnect")
        XCTAssertEqual(ErrorState(rawValue: 0x04), .notAuthorized, "Expected 0x04 to initialize to notAuthorized")
        XCTAssertEqual(ErrorState(rawValue: 0xff), .unknown, "Expected 0xff to initialize to unknown")
    }
}
