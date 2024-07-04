//
//  ImprovDevice.swift
//  Improv-iOS
//
//  Created by Bruno Pantaleão on 03/07/2024.
//

import Foundation

public struct ImprovDevice {
    public init(name: String, address: String) {
        self.name = name
        self.address = address
    }
    
    public let name: String
    public let address: String
}
