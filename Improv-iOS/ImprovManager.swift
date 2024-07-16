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
    var delegate: ImprovManagerDelegate? { get set }

    func scan()
    func stopScan()
    func connectToDevice(_ peripheral: CBPeripheral)
    func disconnectFromDevice(_ peripheral: CBPeripheral)
    func identifyDevice() -> BluetoothManagerError?
    func sendWifi(ssid: String, password: String) -> BluetoothManagerError?
    func reset()
}

public protocol ImprovManagerDelegate: AnyObject {
    func didUpdateBluetoohState(_ state: CBManagerState)

    func didUpdateFoundDevices(devices: [String : CBPeripheral])

    func didConnect(peripheral: CBPeripheral)

    func didDisconnect(peripheral: CBPeripheral)

    func didUpdateDeviceState(_ state: DeviceState?)

    func didUpdateErrorState(_ state: ErrorState?)

    func didReceiveResult(_ result: [String]?)

    func didReset()
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
    weak public var delegate: ImprovManagerDelegate?

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
        foundDevices = [:]
        delegate?.didUpdateFoundDevices(devices: foundDevices)
    }

    public func connectToDevice(_ peripheral: CBPeripheral) {
        bluetoothManager.connectToDevice(peripheral)
    }

    public func disconnectFromDevice(_ peripheral: CBPeripheral) {
        connectedDevice = nil
        bluetoothManager.disconnectFromDevice(peripheral)
    }

    public func identifyDevice() -> BluetoothManagerError? {
        bluetoothManager.identifyDevice()
    }

    public func sendWifi(ssid: String, password: String) -> BluetoothManagerError? {
        bluetoothManager.sendWifi(ssid: ssid, password: password)
    }

    public func reset() {
        stopScan()
        bluetoothState = bluetoothManager.state
        errorState = nil
        deviceState = nil
        lastResult = nil
        foundDevices = [String: CBPeripheral]()
        connectedDevice = nil

        delegate?.didReset()
    }
}

extension ImprovManager: BluetoothManagerDelegate {
    func didUpdateBluetoohState(_ state: CBManagerState) {
        bluetoothState = state
        delegate?.didUpdateBluetoohState(state)
    }

    func didFindNewDevice(peripheral: CBPeripheral) {
        foundDevices[peripheral.identifier.uuidString] = peripheral
        delegate?.didUpdateFoundDevices(devices: foundDevices)
    }

    func didConnect(peripheral: CBPeripheral) {
        connectedDevice = peripheral
        delegate?.didConnect(peripheral: peripheral)
    }

    func didDisconnect(peripheral: CBPeripheral) {
        connectedDevice = nil
        delegate?.didDisconnect(peripheral: peripheral)
    }

    func didUpdateDeviceState(_ state: DeviceState?) {
        deviceState = state
        delegate?.didUpdateDeviceState(state)
    }

    func didUpdateErrorState(_ state: ErrorState?) {
        errorState = state
        delegate?.didUpdateErrorState(state)
    }

    func didReceiveResult(_ result: [String]?) {
        lastResult = result
        delegate?.didReceiveResult(result)
    }
}
