//
//  Logger.swift
//  Improv-iOS
//
//  Created by Bruno Pantaleão on 03/07/2024.
//

import Foundation

import OSLog

extension Logger {
    /// Using your bundle identifier is a great way to ensure a unique identifier.
    private static var subsystem = Bundle.main.bundleIdentifier!

    static let main = Logger(subsystem: subsystem, category: "main")
}
