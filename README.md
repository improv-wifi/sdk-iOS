# ``iOS SDK for Improv Wi-Fi``

This library is for dealing with the complexities of the Bluetooth connection not creating any UI. You as the developer are responible for creating the UI/UX. A demo App is available in Improv-iOS-Demo.

## Quick start

You can check the demo app or follow that:

```
var improvManager = ImprovManager()

// Start scanning for Improv devices
improvManager.scan()

// Stop scanning for Improv devices
improvManager.stopScan()

// @Published variable with devices found
let devices = improvManager.foundDevices

// Connect to device before sending commands
improvManager.connectToDevice(peripheral)

// Identify device
improvManager.identifyDevice()

// Connect device to WiFi network
improvManager.sendWifi(ssid: ssid, password: password)

// Listen for status updates
// SwiftUI example
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
```
