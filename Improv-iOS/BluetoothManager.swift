//
//  BluetoothManager.swift
//  Improv-iOS
//
//  Created by Bruno Pantaleão on 11/07/2024.
//

import Foundation
import CoreBluetooth
import OSLog

protocol BluetoothManagerDelegate: AnyObject {
    func didUpdateBluetoohState(_ state: CBManagerState)
    func didUpdateDeviceState(_ state: DeviceState?)
    func didUpdateErrorState(_ state: ErrorState?)
    func didFindNewDevice(peripheral: CBPeripheral)
    func didConnect(peripheral: CBPeripheral)
    func didDisconnect(peripheral: CBPeripheral)
    func didReceiveResult(_ result: [String]?)
}

protocol BluetoothManagerProtocol {
    var delegate: BluetoothManagerDelegate? { get set }
    var state: CBManagerState { get }

    func scan()
    func stopScan()
    func connectToDevice(_ peripheral: CBPeripheral)
    func disconnectFromDevice(_ peripheral: CBPeripheral)
    func identifyDevice() -> BluetoothManagerError?
    func sendWifi(ssid: String, password: String) -> BluetoothManagerError?
}

public enum BluetoothManagerError: Error {
    case deviceDisconnected
    case serviceNotAvailable
}

final class BluetoothManager: NSObject, BluetoothManagerProtocol {

    private var centralManager: CBCentralManager
    weak var delegate: BluetoothManagerDelegate?

    var state: CBManagerState {
        centralManager.state
    }

    private var bluetoothGatt: CBPeripheral?
    private var operationQueue = [BleOperationType]()
    private var pendingOperation: BleOperationType?

    override init() {
        self.centralManager = CBCentralManager()
        super.init()

        centralManager.delegate = self
    }

    func scan() {
        let scanOptions: [String: Any] = [CBCentralManagerScanOptionAllowDuplicatesKey: false]
        centralManager.scanForPeripherals(withServices: [BluetoothUUIDs.serviceProvision], options: scanOptions)
    }

    func stopScan() {
        centralManager.stopScan()
    }

    func connectToDevice(_ peripheral: CBPeripheral) {
        enqueueOperation(Connect(device: peripheral))
    }

    func disconnectFromDevice(_ peripheral: CBPeripheral) {
        bluetoothGatt = nil
        centralManager.cancelPeripheralConnection(peripheral)
    }

    func identifyDevice() -> BluetoothManagerError? {
        guard let gatt = bluetoothGatt else {
            return .deviceDisconnected
        }
        if let rpc = gatt.services?.first(where: { $0.uuid == BluetoothUUIDs.serviceProvision })?.characteristics?.first(where: { $0.uuid == BluetoothUUIDs.charRpc }) {
            sendRpc(rpc, command: .identify, data: [])
            return nil
        } else {
            return .serviceNotAvailable
        }
    }

    func sendWifi(ssid: String, password: String) -> BluetoothManagerError? {
        guard let gatt = bluetoothGatt else {
            return .deviceDisconnected
        }
        if let rpc = gatt.services?.first(where: { $0.uuid == BluetoothUUIDs.serviceProvision })?.characteristics?.first(where: { $0.uuid == BluetoothUUIDs.charRpc }) {
            let encodedSsid = Array(ssid.utf8)
            let encodedPassword = Array(password.utf8)
            let data = [UInt8(encodedSsid.count)] + encodedSsid + [UInt8(encodedPassword.count)] + encodedPassword
            sendRpc(rpc, command: .sendWifi, data: data)
            return nil
        } else {
            return .serviceNotAvailable
        }
    }

    private func sendRpc(_ rpc: CBCharacteristic, command: RpcCommand, data: [UInt8]) {
        var commandArray = [command.rawValue, UInt8(data.count)] + data
        commandArray = commandArray + [calculateChecksum(data: commandArray)]
        Logger.main.info("Sending \(commandArray.map { String($0) })")
        enqueueOperation(CharacteristicWrite(char: rpc, data: Data(commandArray)))
    }

    private func calculateChecksum(data: [UInt8]) -> UInt8 {
        var checksum: UInt8 = 0
        for byte in data {
            checksum = (checksum &+ byte) & 255 // Calculate and keep it within 0-255 range
        }
        return checksum
    }

    private func enqueueOperation(_ operation: BleOperationType) {
        operationQueue.append(operation)
        if pendingOperation == nil {
            doNextOperation()
        }
    }

    private func doNextOperation() {
        if pendingOperation != nil {
            Logger.main.info("doNextOperation() called when an operation is pending! Aborting.")
            return
        }

        guard let operation = operationQueue.first else {
            Logger.main.info("Operation queue empty, returning")
            return
        }
        pendingOperation = operation
        operationQueue.removeFirst()

        switch operation {
        case let connect as Connect:
            centralManager.connect(connect.device, options: nil)
        case let write as CharacteristicWrite:
            bluetoothGatt?.writeValue(write.data, for: write.char, type: .withResponse)
        case let read as CharacteristicRead:
            bluetoothGatt?.readValue(for: read.char)
        case let write as DescriptorWrite:
            bluetoothGatt?.writeValue(write.data, for: write.desc)
        default:
            fatalError("Unhandled Operation!")
        }
        pendingOperation = nil
    }

    private func signalEndOfOperation() {
        Logger.main.info("End of \(String(describing: self.pendingOperation))")
        pendingOperation = nil
        if !operationQueue.isEmpty {
            doNextOperation()
        }
    }

    private func updateStates(_ peripheral: CBPeripheral, service: CBService) {
        guard service.uuid == BluetoothUUIDs.serviceProvision else { return }
        if let currentStateChar = service.characteristics?.first(where: { $0.uuid == BluetoothUUIDs.charCurrentState }) {
            enqueueOperation(CharacteristicRead(char: currentStateChar))
            peripheral.setNotifyValue(true, for: currentStateChar)
        }

        if let errorStateChar = service.characteristics?.first(where: { $0.uuid == BluetoothUUIDs.charErrorState }) {
            enqueueOperation(CharacteristicRead(char: errorStateChar))
            peripheral.setNotifyValue(true, for: errorStateChar)
        }

        if let resultChar = service.characteristics?.first(where: { $0.uuid == BluetoothUUIDs.charRpcResult }) {
            enqueueOperation(CharacteristicRead(char: resultChar))
            peripheral.setNotifyValue(true, for: resultChar)
        }
    }
}

extension BluetoothManager: CBCentralManagerDelegate {
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        delegate?.didUpdateBluetoohState(central.state)
    }

    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        Logger.main.info("Found BLE device! Name: \(peripheral.name ?? "Unnamed"), address: \(peripheral.identifier.uuidString)")
        delegate?.didFindNewDevice(peripheral: peripheral)

    }

    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        Logger.main.info("Successfully connected to \(peripheral.identifier.uuidString), discovering services.")
        delegate?.didConnect(peripheral: peripheral)
        bluetoothGatt = peripheral
        peripheral.delegate = self
        peripheral.discoverServices([BluetoothUUIDs.serviceProvision])
    }

    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        Logger.main.info("Successfully disconnected from \(peripheral.identifier.uuidString)")
        bluetoothGatt = nil
        delegate?.didConnect(peripheral: peripheral)
        if pendingOperation is Connect {
            signalEndOfOperation()
        }
    }
}

extension BluetoothManager: CBPeripheralDelegate {
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: (any Error)?) {
        Logger.main.info("didDiscoverCharacteristicsFor service: \(service)")
        updateStates(peripheral, service: service)
    }

    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else {
            Logger.main.info("No Services Found!!")
            return
        }

        for service in services {
            Logger.main.info("Found service: \(service.uuid)")
            peripheral.discoverCharacteristics(nil, for: service)
        }

        if let service = services.first(where: { $0.uuid == BluetoothUUIDs.serviceProvision }) {
            updateStates(peripheral, service: service)
        }
    }

    @MainActor
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil else {
            Logger.main.info("Error reading characteristic: \(error!.localizedDescription)")
            return
        }

        if let value = characteristic.value {
            let intValue = value.first ?? 0
            switch characteristic.uuid {
            case BluetoothUUIDs.charCurrentState:
                Logger.main.info("Current State has changed to \(intValue).")
                if let deviceState = DeviceState(rawValue: intValue) {
                    delegate?.didUpdateDeviceState(deviceState)
                } else {
                    Logger.main.info("Unable to determine Current State")
                    delegate?.didUpdateDeviceState(nil)
                }
            case BluetoothUUIDs.charErrorState:
                Logger.main.info("Error State has changed to \(intValue).")
                if let errorState = ErrorState(rawValue: intValue) {
                    delegate?.didUpdateErrorState(errorState)
                } else {
                    Logger.main.info("Unable to determine Error State")
                    delegate?.didUpdateErrorState(nil)
                }
            case BluetoothUUIDs.charRpcResult:
                Logger.main.info("Result changed to \(value).")
                delegate?.didReceiveResult(extractResultStrings(from: value))
            default:
                break
            }
        }
    }

    private func extractResultStrings(from data: Data) -> [String]? {
        // Ensure the data is at least 3 bytes long to read the first string length
        guard data.count > 2 else { return nil }

        var strings: [String] = []
        var currentIndex = 2 // Start after the first two bytes

        while currentIndex < data.count {
            // Get the length of the current string
            let stringLength = Int(data[currentIndex])
            currentIndex += 1

            // Ensure there are enough bytes left for the current string
            guard currentIndex + stringLength <= data.count else { return strings }

            // Extract the string data
            let stringData = data.subdata(in: currentIndex..<(currentIndex + stringLength))
            currentIndex += stringLength

            // Convert the string data to a String and add it to the list
            if let string = String(data: stringData, encoding: .utf8) {
                strings.append(string)
            } else {
                return strings // Invalid string encoding, return strings previously decoded
            }
        }

        return strings
    }

    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if error == nil {
            Logger.main.info("Char \(characteristic.uuid) write complete")
            Logger.main.info("Full char \(characteristic)")
        } else {
            Logger.main.info("Char \(characteristic.uuid) not written!!")
        }
        if pendingOperation is CharacteristicWrite {
            signalEndOfOperation()
        }
    }

    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) {
        if error == nil {
            Logger.main.info("Desc \(descriptor.uuid) write complete")
        } else {
            Logger.main.info("Desc \(descriptor.uuid) not written!!")
        }
        if pendingOperation is DescriptorWrite {
            signalEndOfOperation()
        }
    }
}
