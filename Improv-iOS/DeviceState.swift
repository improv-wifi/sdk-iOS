//
//  DeviceState.swift
//  Improv-iOS
//
//  Created by Bruno Pantaleão on 03/07/2024.
//

import Foundation

public enum DeviceState: UInt8 {
    case authorizationRequired = 0x01
    case authorized = 0x02
    case provisioning = 0x03
    case provisioned = 0x04
}
