//
//  DeviceView.swift
//  Improv-iOS-Demo
//
//  Created by Bruno Pantaleão on 04/07/2024.
//

import SwiftUI
import CoreBluetooth
import Improv_iOS

struct DeviceView<Manager>: View where Manager: ImprovManagerProtocol {
    @EnvironmentObject private var improvManager: Manager
    @State private var ssid = ""
    @State private var password = ""
    let peripheral: CBPeripheral

    var body: some View {
        List {
            Text(peripheral.name ?? peripheral.identifier.uuidString)
            Text("Connected: \(improvManager.connectedDevice?.identifier == peripheral.identifier)")
            Text("Bluetooth State: \(improvManager.bluetoothState.description)")
            Text("Device State: \(String(describing: improvManager.deviceState ?? .none))")
            Text("Error state: \(String(describing: improvManager.errorState ?? .none))")
            if let result = improvManager.lastResult {
                Section("Result strings") {
                    ForEach(result, id: \.self) { string in
                        Text(string)
                    }
                }
            }

            Section {
                Button(action: {
                    improvManager.connectToDevice(peripheral)
                }, label: {
                    Text("Connect")
                })
            }
            Section {
                Button(action: {
                    if let error = improvManager.identifyDevice() {
                        print("ERROR while identify command: \(error)")
                    }
                }, label: {
                    Text("Identify")
                })
            }
            .disabled(improvManager.connectedDevice?.identifier != peripheral.identifier)

            Section {
                TextField("SSID", text: $ssid)
                TextField("Password", text: $password)
                Button(action: {
                    if let error = improvManager.sendWifi(ssid: ssid, password: password) {
                        print("ERROR while sendWifi command: \(error)")
                    }
                }, label: {
                    Text("Connect to Wifi")
                })
            }
            .disabled(improvManager.connectedDevice?.identifier != peripheral.identifier)
        }
    }
}
