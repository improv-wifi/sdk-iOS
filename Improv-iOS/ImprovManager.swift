import Foundation
import Combine
import CoreBluetooth
import OSLog

public protocol ImprovManagerProtocol: ObservableObject {
    var bluetoothState: CBManagerState { get }
    var errorState: ErrorState? { get }
    var deviceState: DeviceState? { get }
    var lastResult: [String]? { get }
    var foundDevices: [String : CBPeripheral] { get }
    var scanInProgress: Bool { get }
    var connectedDevice: CBPeripheral? { get }

    func scan()
    func stopScan()
    func connectToDevice(_ peripheral: CBPeripheral)
    func identifyDevice()
    func sendWifi(ssid: String, password: String)
}

public final class ImprovManager: NSObject, ImprovManagerProtocol {
    enum State {
        case idle
        case result(devices: [String])
        case bluetoothOff
    }

    public static var shared: any ImprovManagerProtocol = ImprovManager(
        bluetoothManager: BluetoothManager()
    )

    private var bluetoothManager: BluetoothManagerProtocol

    @Published public private(set) var bluetoothState: CBManagerState = .unknown
    @Published public private(set) var errorState: ErrorState?
    @Published public private(set) var deviceState: DeviceState?
    @Published public private(set) var lastResult: [String]?
    @Published public private(set) var foundDevices: [String : CBPeripheral] = [String: CBPeripheral]()
    @Published public private(set) var connectedDevice: CBPeripheral? {
        didSet {
            if connectedDevice == nil {
                deviceState = nil
                errorState = nil
            }
        }
    }
    @Published public private(set) var scanInProgress = false

    internal init(bluetoothManager: BluetoothManagerProtocol) {
        self.bluetoothManager = bluetoothManager
        super.init()
        self.bluetoothManager.delegate = self
    }

    public func scan() {
        bluetoothState = bluetoothManager.state
        if bluetoothState == .poweredOn {
            bluetoothManager.scan()
            scanInProgress = true
        }
    }

    public func stopScan() {
        bluetoothManager.stopScan()
        scanInProgress = false
    }

    public func connectToDevice(_ peripheral: CBPeripheral) {
        stopScan()
        bluetoothManager.connectToDevice(peripheral)
    }

    public func identifyDevice() {
        bluetoothManager.identifyDevice()
    }

    public func sendWifi(ssid: String, password: String) {
        bluetoothManager.sendWifi(ssid: ssid, password: password)
    }
}

extension ImprovManager: BluetoothManagerDelegate {
    func didUpdateBluetoohState(_ state: CBManagerState) {
        bluetoothState = state
    }

    func didFindNewDevice(peripheral: CBPeripheral) {
        foundDevices[peripheral.identifier.uuidString] = peripheral
    }

    func didConnect(peripheral: CBPeripheral) {
        connectedDevice = peripheral
    }

    func didDisconnect(peripheral: CBPeripheral) {
        connectedDevice = nil
    }

    func didUpdateDeviceState(_ state: DeviceState?) {
        deviceState = state
    }

    func didUpdateErrorState(_ state: ErrorState?) {
        errorState = state
    }

    func didReceiveResult(_ result: [String]?) {
        lastResult = result
    }
}
