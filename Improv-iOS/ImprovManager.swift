import Foundation
import Combine
import CoreBluetooth
import OSLog

public final class ImprovManager: NSObject, ObservableObject {
    enum State {
        case idle
        case result(devices: [String])
        case bluetoothOff
    }

    private let uuidServiceProvision = CBUUID(string: "00467768-6228-2272-4663-277478268000")
    private let uuidCharCurrentState = CBUUID(string: "00467768-6228-2272-4663-277478268001")
    private let uuidCharErrorState = CBUUID(string: "00467768-6228-2272-4663-277478268002")
    private let uuidCharRpc = CBUUID(string: "00467768-6228-2272-4663-277478268003")
    private let uuidCharRpcResult = CBUUID(string: "00467768-6228-2272-4663-277478268004")

    private var centralManager: CBCentralManager!
    private var operationQueue = [BleOperationType]()
    private var pendingOperation: BleOperationType?
    private var bluetoothGatt: CBPeripheral?

    @Published public var bluetoothState: CBManagerState = .unknown
    @Published public var errorState: ErrorState?
    @Published public var deviceState: DeviceState?
    @Published public var lastResult: [String]?
    @Published public var foundDevices: [String : CBPeripheral] = [String: CBPeripheral]()
    @Published public var connectedDevice: CBPeripheral? {
        didSet {
            if connectedDevice == nil {
                deviceState = nil
                errorState = nil
            }
        }
    }
    @Published public var scanInProgress = false


    public override init() {
        super.init()
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    public func scan() {
        bluetoothState = centralManager.state
        if centralManager.state == .poweredOn {
            let scanOptions: [String: Any] = [CBCentralManagerScanOptionAllowDuplicatesKey: false]
            centralManager.scanForPeripherals(withServices: [uuidServiceProvision], options: scanOptions)
            scanInProgress = true
        }
    }

    public func stopScan() {
        centralManager.stopScan()
        scanInProgress = false
    }

    public func connectToDevice(_ peripheral: CBPeripheral) {
        stopScan()
        enqueueOperation(Connect(device: peripheral))
    }

    public func identifyDevice() {
        guard let gatt = bluetoothGatt else {
            fatalError("Not Connected to a Device!")
        }
        if let rpc = gatt.services?.first(where: { $0.uuid == uuidServiceProvision })?.characteristics?.first(where: { $0.uuid == uuidCharRpc }) {
            sendRpc(rpc, command: .identify, data: [])
        }
    }

    public func sendWifi(ssid: String, password: String) {
        guard let gatt = bluetoothGatt else {
            fatalError("Not Connected to a Device!")
        }
        if let rpc = gatt.services?.first(where: { $0.uuid == uuidServiceProvision })?.characteristics?.first(where: { $0.uuid == uuidCharRpc }) {
            let encodedSsid = Array(ssid.utf8)
            let encodedPassword = Array(password.utf8)
            let data = [UInt8(encodedSsid.count)] + encodedSsid + [UInt8(encodedPassword.count)] + encodedPassword
            sendRpc(rpc, command: .sendWifi, data: data)
        }
    }

    private func sendRpc(_ rpc: CBCharacteristic, command: RpcCommand, data: [UInt8]) {
        var commandArray = [command.rawValue, UInt8(data.count)] + data
        commandArray = commandArray + [calculateChecksum(data: commandArray)]
        Logger.main.info("Sending \(commandArray.map { String($0) })")
        enqueueOperation(CharacteristicWrite(char: rpc, data: Data(commandArray)))
    }

    func calculateChecksum(data: [UInt8]) -> UInt8 {
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
        guard service.uuid == uuidServiceProvision else { return }
        if let currentStateChar = service.characteristics?.first(where: { $0.uuid == uuidCharCurrentState }) {
            enqueueOperation(CharacteristicRead(char: currentStateChar))
            peripheral.setNotifyValue(true, for: currentStateChar)
        }

        if let errorStateChar = service.characteristics?.first(where: { $0.uuid == uuidCharErrorState }) {
            enqueueOperation(CharacteristicRead(char: errorStateChar))
            peripheral.setNotifyValue(true, for: errorStateChar)
        }

        if let resultChar = service.characteristics?.first(where: { $0.uuid == uuidCharRpcResult }) {
            enqueueOperation(CharacteristicRead(char: resultChar))
            peripheral.setNotifyValue(true, for: resultChar)
        }
    }
}

extension ImprovManager: CBCentralManagerDelegate {
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        bluetoothState = central.state
    }

    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        Logger.main.info("Found BLE device! Name: \(peripheral.name ?? "Unnamed"), address: \(peripheral.identifier.uuidString)")
        foundDevices[peripheral.identifier.uuidString] = peripheral
    }

    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        Logger.main.info("Successfully connected to \(peripheral.identifier.uuidString), discovering services.")
        bluetoothGatt = peripheral
        connectedDevice = peripheral
        peripheral.delegate = self
        peripheral.discoverServices([uuidServiceProvision])
    }

    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        Logger.main.info("Successfully disconnected from \(peripheral.identifier.uuidString)")
        bluetoothGatt = nil
        connectedDevice = nil
        if pendingOperation is Connect {
            signalEndOfOperation()
        }
    }
}

extension ImprovManager: CBPeripheralDelegate {

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

        if let service = services.first(where: { $0.uuid == uuidServiceProvision }) {
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
            case uuidCharCurrentState:
                Logger.main.info("Current State has changed to \(intValue).")
                if let deviceState = DeviceState(rawValue: intValue) {
                    self.deviceState = deviceState
                } else {
                    Logger.main.info("Unable to determine Current State")
                    self.deviceState = nil
                }
            case uuidCharErrorState:
                Logger.main.info("Error State has changed to \(intValue).")
                if let errorState = ErrorState(rawValue: intValue) {
                    self.errorState = errorState
                } else {
                    Logger.main.info("Unable to determine Error State")
                    self.errorState = nil
                }
            case uuidCharRpcResult:
                Logger.main.info("Result changed to \(value).")
                let resultStrings = extractResultStrings(from: value)
                #if DEBUG
                print(resultStrings)
                #endif
                self.lastResult = resultStrings
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
