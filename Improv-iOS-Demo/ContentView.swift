//
//  ContentView.swift
//  Improv-iOS-Demo
//
//  Created by Bruno Pantaleão on 03/07/2024.
//

import SwiftUI
import Improv_iOS
import CoreBluetooth

struct ContentView<Manager>: View where Manager: ImprovManagerProtocol {
    @StateObject private var improvManager: Manager
    @State private var showConnect = false

    init() {
        self._improvManager = .init(wrappedValue: ImprovManager.shared as! Manager)
    }

    var body: some View {
        NavigationView {
            List {
                VStack {
                    Text("Bluetooth state")
                        .font(.footnote)
                        .foregroundStyle(.gray)
                    Text(String("\(improvManager.bluetoothState.description)"))
                }
                Button {
                    if improvManager.scanInProgress {
                        improvManager.stopScan()

                    } else {
                        improvManager.scan()
                    }

                } label: {
                    if improvManager.scanInProgress {
                        Text("Stop scan")
                    } else {
                        Text("Scan for devices")
                    }
                }
                Text("Count: \(improvManager.foundDevices.count)")
                ForEach(improvManager.foundDevices.keys.sorted(), id: \.self) { peripheralKey in
                    if let peripheral = improvManager.foundDevices[peripheralKey] {
                        NavigationLink {
                            DeviceView<ImprovManager>(peripheral: peripheral)
                                .environmentObject(improvManager)
                        } label: {
                            Text(peripheral.name ?? peripheral.identifier.uuidString)
                        }
                    }
                }
            }
            .navigationTitle("Improv - iOS")
        }
    }
}

extension CBManagerState {
    var description: String {
        switch self {
        case .unknown:
            return "unknown"
        case .resetting:
            return "resetting"
        case .unsupported:
            return "unsupported"
        case .unauthorized:
            return "unauthorized"
        case .poweredOff:
            return "poweredOff"
        case .poweredOn:
            return "poweredOn"
        @unknown default:
            return "unknown"
        }
    }
}
