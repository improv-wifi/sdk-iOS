//
//  BluetoothUUIDsTests.swift
//  Improv-iOSTests
//
//  Created by Bruno Pantaleão on 11/07/2024.
//

import XCTest
@testable import Improv_iOS

final class BluetoothUUIDsTests: XCTestCase {

    func test_BluetoothUUIDs_ids() {
        XCTAssertEqual(BluetoothUUIDs.serviceProvision.uuidString, "00467768-6228-2272-4663-277478268000")
        XCTAssertEqual(BluetoothUUIDs.charCurrentState.uuidString, "00467768-6228-2272-4663-277478268001")
        XCTAssertEqual(BluetoothUUIDs.charErrorState.uuidString, "00467768-6228-2272-4663-277478268002")
        XCTAssertEqual(BluetoothUUIDs.charRpc.uuidString, "00467768-6228-2272-4663-277478268003")
        XCTAssertEqual(BluetoothUUIDs.charRpcResult.uuidString, "00467768-6228-2272-4663-277478268004")
    }
}
