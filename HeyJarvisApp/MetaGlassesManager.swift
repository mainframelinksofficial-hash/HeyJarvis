//
//  MetaGlassesManager.swift
//  HeyJarvisApp
//
//  Meta Ray-Ban Glasses integration via Wearables SDK
//  Note: Requires Meta Wearables SDK (developer preview)
//

import Foundation
import CoreBluetooth
import AVFoundation

// MARK: - Meta Glasses Connection State
enum MetaGlassesState: String {
    case disconnected = "Disconnected"
    case searching = "Searching..."
    case connecting = "Connecting..."
    case connected = "Connected"
    case ready = "Ready"
}

// MARK: - Meta Glasses Manager
class MetaGlassesManager: NSObject, ObservableObject {
    static let shared = MetaGlassesManager()
    
    @Published var connectionState: MetaGlassesState = .disconnected
    @Published var isGlassesConnected: Bool = false
    @Published var batteryLevel: Int = 0
    @Published var lastError: String?
    
    private var centralManager: CBCentralManager?
    private var metaGlassesPeripheral: CBPeripheral?
    
    // Meta Glasses Bluetooth UUIDs (these are placeholder UUIDs - actual ones from Meta SDK)
    private let metaServiceUUID = CBUUID(string: "0000180F-0000-1000-8000-00805F9B34FB")
    private let metaCharacteristicUUID = CBUUID(string: "00002A19-0000-1000-8000-00805F9B34FB")
    
    // Callbacks
    var onGlassesConnected: (() -> Void)?
    var onGlassesDisconnected: (() -> Void)?
    var onPhotoRequested: (() -> Void)?
    var onVideoRequested: (() -> Void)?
    
    private override init() {
        super.init()
    }
    
    func startSearching() {
        connectionState = .searching
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func stopSearching() {
        centralManager?.stopScan()
        connectionState = .disconnected
    }
    
    func disconnect() {
        if let peripheral = metaGlassesPeripheral {
            centralManager?.cancelPeripheralConnection(peripheral)
        }
        metaGlassesPeripheral = nil
        isGlassesConnected = false
        connectionState = .disconnected
    }
    
    // MARK: - Audio Output to Glasses
    
    /// Route audio to Meta glasses speakers if connected
    func routeAudioToGlasses() {
        guard isGlassesConnected else { return }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            // Try to route to Bluetooth device (glasses)
            try audioSession.setCategory(.playback, mode: .default, options: [.allowBluetooth, .allowBluetoothA2DP])
            try audioSession.setActive(true)
            
            // Find Bluetooth output
            if let outputs = audioSession.currentRoute.outputs.first(where: { $0.portType == .bluetoothA2DP || $0.portType == .bluetoothHFP }) {
                print("Audio routed to: \(outputs.portName)")
            }
        } catch {
            print("Failed to route audio to glasses: \(error)")
        }
    }
    
    // MARK: - Simulated Glasses Actions
    // These simulate what the Meta Wearables SDK would do
    
    func triggerGlassesPhoto() async -> Bool {
        guard isGlassesConnected else {
            lastError = "Glasses not connected"
            return false
        }
        
        // In real implementation, this would use Meta Wearables SDK
        // For now, we simulate the action
        onPhotoRequested?()
        return true
    }
    
    func triggerGlassesVideo() async -> Bool {
        guard isGlassesConnected else {
            lastError = "Glasses not connected"
            return false
        }
        
        onVideoRequested?()
        return true
    }
    
    func sendAudioToGlasses(_ audioData: Data) {
        guard isGlassesConnected else { return }
        
        // Route audio playback to Bluetooth (glasses)
        routeAudioToGlasses()
        
        // In real implementation, you'd use Meta Wearables SDK to stream audio
        // For now, standard AVAudioPlayer will route to connected Bluetooth device
    }
}

// MARK: - CBCentralManagerDelegate
extension MetaGlassesManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            // Start scanning for Meta glasses
            central.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
            connectionState = .searching
        case .poweredOff:
            connectionState = .disconnected
            lastError = "Bluetooth is off"
        case .unauthorized:
            connectionState = .disconnected
            lastError = "Bluetooth permission denied"
        default:
            break
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        // Look for Meta/Ray-Ban devices
        let name = peripheral.name?.lowercased() ?? ""
        if name.contains("ray-ban") || name.contains("meta") || name.contains("rayban") {
            metaGlassesPeripheral = peripheral
            central.stopScan()
            central.connect(peripheral, options: nil)
            connectionState = .connecting
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices(nil)
        connectionState = .connected
        isGlassesConnected = true
        onGlassesConnected?()
        
        // Route audio to glasses
        routeAudioToGlasses()
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        isGlassesConnected = false
        connectionState = .disconnected
        onGlassesDisconnected?()
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        connectionState = .disconnected
        lastError = error?.localizedDescription ?? "Failed to connect"
    }
}

// MARK: - CBPeripheralDelegate
extension MetaGlassesManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        
        for characteristic in characteristics {
            // Subscribe to notifications for battery level, etc.
            if characteristic.properties.contains(.notify) {
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
        
        connectionState = .ready
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        // Handle incoming data from glasses
        if characteristic.uuid == metaCharacteristicUUID,
           let data = characteristic.value {
            // Parse battery level or other status
            if data.count >= 1 {
                batteryLevel = Int(data[0])
            }
        }
    }
}
