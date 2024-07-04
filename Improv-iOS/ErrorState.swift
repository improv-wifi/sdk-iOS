//
//  ErrorState.swift
//  Improv-iOS
//
//  Created by Bruno Pantaleão on 03/07/2024.
//

import Foundation

public enum ErrorState: UInt8 {
    case noError = 0x00
    case invalidRPCPacket = 0x01
    case unknownCommand = 0x02
    case unableToConnect = 0x03
    case notAuthorized = 0x04
    case unknown = 0xff
}
