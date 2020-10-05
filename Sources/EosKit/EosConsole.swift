//
//  EosConsole.swift
//  EosKit
//
//  Created by Sam Smallman on 12/05/2020.
//  Copyright © 2020 Sam Smallman. https://github.com/SammySmallman
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation
import OSCKit

public protocol EosConsoleDelegate {
    func console(_ console: EosConsole, didUpdateState state: EosConsoleState)
    func console(_ console: EosConsole, didReceiveUndefinedMessage message: String)
    func console(_ console: EosConsole, didCompleteSynchronisingOptions options: Set<EosConsoleOption>)
}

/// Represents the current state of an EosConsole.
public enum EosConsoleState: Int {
    case unknown = 0
    case disconnected = 1
    case connected = 2
    case unresponsive = 3
    case responsive = 4
}

/// The type of eos family console the `EosConsole` represents.
public enum EosConsoleType: String {
    case nomad = "ETCnomad"
    case nomadPuck = "ETCnomad Puck"
    case element = "Element"
    case element2 = "Element2"
    case ion = "Ion"
    case ionXE = "IonXE"
    case ionXE20 = "IonXE20"
    case eos = "Eos"
    case eosRVI = "Eos RVI"
    case eosRPU = "Eos RPU"
    case ti = "Ti"
    case gio = "Gio"
    case gio5 = "Gio@5"
    case unknown
}

public enum EosConsoleOption: Int {
    case cues
    case patch
    
    var filters: Set<String> {
        switch self {
        case .cues:
            return eosCuesFilters
        case .patch:
            return eosPatchFilters
        }
    }
}

public final class EosConsole: NSObject, Identifiable {
    
    /// The current state of the console.
    ///
    /// This state is initially set to `EosConsoleState.unknown`. When the state updates, the console calls its delegate's console(_ console: `EosConsole`, didUpdateState state: `EosConsoleState`) method.
    /// This state can only be anything other than `EosConsoleState.disconnected` or `EosConsoleState.unknown` if `isConnected` is `true`.
    private(set) public var state: EosConsoleState = .unknown { didSet { delegate?.console(self, didUpdateState: state) }}
    
    /// The current optional functionality of the console.
    ///
    /// An eos family console can provide information regarding many parts of its systems, for example, cue lists, patch, presets and palettes.
    /// To request and gain a syncronous data store to parts of the eos family console this options should be inserted with the corresponding `EosConsoleOption`.
    public var options: Set<EosConsoleOption> = [] { didSet { consoleOptionsDidChange(from: oldValue, to: options) }}
    
    /// The current filters applied to the console.
    ///
    /// As `options` are changed filters are added and removed to the console to limit the OSC messages to those that are strictly necesary.
    private(set) public var filters: Set<String> = []
    
    private var completionHandlers: [String : EosKitCompletionHandler] = [:]
    private let client = OSCClient()
    private let uuid = UUID()
    private var heartbeats = -1 // Not running
    private var heartbeatTimer: Timer?
    private var systemFiltersSent = false
    
    public let name: String
    public let type: EosConsoleType
    private(set) var interface: String { get { client.interface ?? "" } set { client.interface = newValue } }
    private(set) var host: String { get { client.host ?? "localhost" } set { client.host = newValue } }
    private(set) var port: UInt16 { get { client.port } set { client.port = newValue } }
    
    /// The current state of the TCP connection.
    ///
    /// This state represents the connection of the clients socket tcp connection used by this `EosConsole`.
    /// It differs from `EosConsoleState` in that it is showing the status of the socket connection and not whether or not OSC communication is currently possible between this `EosConsole` and an eos family console.
    public var isConnected: Bool { get { return client.isConnected } }
    public var delegate: EosConsoleDelegate?
    
    private var observationContext = 1
    private var progress = Progress(totalUnitCount: -1)
    public var progressHandler: ((Double, String, String) -> Void)?
    
    private var cuesManager: EosCuesManager?
    private var patchManager: EosPatchManager?
    
    public init(name: String, type: EosConsoleType = .unknown, interface: String = "", host: String, port: UInt16 = 3032) {
        self.name = name
        self.type = type
        client.host = host
        client.port = port
        client.useTCP = true
        client.streamFraming = .SLIP
        print("Initialised with \(name) : \(type.rawValue) : \(interface) : \(host) : \(port)")
    }
    
    deinit {
        print("Deinitialised with \(name) : \(type.rawValue) : \(interface) : \(host) : \(port)")
        progress.removeObserver(self, forKeyPath: "fractionCompleted", context: &observationContext)
    }
    
    public func connect() -> Bool {
        client.delegate = self
        progress.addObserver(self, forKeyPath: "fractionCompleted", options: [], context: &observationContext)
        do {
            try client.connect()
            return true
        } catch {
            return false
        }
    }
    
    public func disconnect() {
        client.disconnect()
        client.delegate = nil
        progress.removeObserver(self, forKeyPath: "fractionCompleted", context: &observationContext)
    }
    
    // MARK:- Heartbeat
    
    public func heartbeat(_ beat: Bool) {
        beat ? startHeartbeat() : stopHeartbeat()
    }
    
    private func startHeartbeat() {
        clearHeartbeatTimeout()
        sendHeartbeat()
    }
    
    private func stopHeartbeat() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(sendHeartbeat), object: nil)
        clearHeartbeatTimeout()
        heartbeats = -1
    }
    
    private func clearHeartbeatTimeout() {
        heartbeatTimer?.invalidate()
        heartbeatTimer = nil
        heartbeats = 0
    }
    
    @objc func sendHeartbeat() {
        sendMessage(with: eosPingRequest, arguments:  [eosHeartbeatString, uuid.uuidString], completionHandler: { [weak self] message in
            
            guard let strongSelf = self, strongSelf.heartbeats > -1 else { return }
            strongSelf.clearHeartbeatTimeout()
            
            guard strongSelf.state != .disconnected && strongSelf.client.isConnected else { return }
            
            if message.isHeartbeat(with: strongSelf.uuid), strongSelf.state != .responsive {
                strongSelf.state = .responsive
                if strongSelf.systemFiltersSent == false {
//                    strongSelf.client.send(packet: OSCMessage(with: eosFiltersAdd, arguments: Array(eosSystemFilters)))
                    strongSelf.filters = strongSelf.filters.union(eosSystemFilters)
                    strongSelf.systemFiltersSent = true
                }
            }
            
            strongSelf.perform(#selector(strongSelf.sendHeartbeat), with: nil, afterDelay: EosConsoleHeartbeatInterval)
        })
        
        heartbeatTimer = Timer(timeInterval: EosConsoleHeartbeatFailureInterval, target: self, selector: #selector(heartbeatTimeout(timer:)), userInfo: nil, repeats: false)
        RunLoop.current.add(heartbeatTimer!, forMode: .common)
    }
    
    @objc func heartbeatTimeout(timer: Timer) {
        guard timer.isValid, heartbeats != -1, state != .disconnected || state != .unknown else { return }
        if state != .unresponsive {
            state = .unresponsive
        }
        sendHeartbeat()
    }
    
    // MARK:- Console Options
    
    private func consoleOptionsDidChange(from fromOptions: Set<EosConsoleOption>, to toOptions: Set<EosConsoleOption>) {
        guard state == .responsive else { return }
        let optionChanges = EosOptionChanges(from: fromOptions, to: toOptions)
//        filter(with: optionChanges)
        synchronise(with: optionChanges)
    }
    
    // MARK:- Filter
    
    private func filter(with changes: EosOptionChanges) {
        let filterChanges = EosFilterChanges(with: changes)
        // A completion handler isn't created as eos does not send a reply to filter add and remove messages... It probably should.
        // TODO: Request eos send replys to /eos/filter/add and /eos/filter/remove.
        switch (filterChanges.add.isEmpty, filterChanges.remove.isEmpty) {
        case (true, true): return
        case (false, false):
            filters = filters.union(filterChanges.add)
            filters = filters.subtracting(filterChanges.remove)
            // TODO: Check whether Eos can handle OSC Bundles...
            // Eos consoles CAN? receive OSCBundles and EosKit sends them to reduce the amount of message sent on the network.
            // The elements within the OSCBundles are actioned upon synscronously by Eos consoles and reply will be as individual OSCMessages.
//            client.send(packet: OSCBundle(bundleWithMessages: [OSCMessage(with: eosFiltersAdd, arguments: Array(filtersToAdd)),
//                                                               OSCMessage(with: eosFiltersRemove, arguments: Array(filtersToRemove))]))
            client.send(packet: OSCMessage(with: eosFiltersAdd, arguments: Array(filterChanges.add)))
            client.send(packet: OSCMessage(with: eosFiltersRemove, arguments: Array(filterChanges.remove)))
        case (false, true):
            filters = filters.union(filterChanges.add)
            client.send(packet: OSCMessage(with: eosFiltersAdd, arguments: Array(filterChanges.add)))
        case (true, false):
            filters = filters.subtracting(filterChanges.remove)
            client.send(packet: OSCMessage(with: eosFiltersRemove, arguments: Array(filterChanges.remove)))
        }
    }
    
    // MARK:- Synchronise
    
    private func synchronise(with changes: EosOptionChanges) {
        addManagers(with: changes.add)
        removeManagers(with: changes.remove)
    }
    
    private func addManagers(with options: Set<EosConsoleOption>) {
        progress.totalUnitCount = Int64(options.count)
        options.forEach({
            switch $0 {
            case .cues:
                let managerProgress = Progress(totalUnitCount: 1)
                cuesManager = EosCuesManager(console: self, progress: managerProgress)
                progress.addChild(managerProgress, withPendingUnitCount: 1)
                cuesManager?.synchronise()
            case .patch:
                let managerProgress = Progress(totalUnitCount: 1)
                patchManager = EosPatchManager(console: self, progress: managerProgress)
                progress.addChild(managerProgress, withPendingUnitCount: 1)
                patchManager?.synchronise()
            }
        })
    }
    
    private func removeManagers(with options: Set<EosConsoleOption>) {
        options.forEach({
            switch $0 {
            case .cues:
                cuesManager = nil
            case .patch:
                return
            }
        })
    }
    
    // MARK:- Send OSC Message
    internal func sendMessage(with addressPattern: String, arguments: [Any], completionHandler: EosKitCompletionHandler? = nil) {
        if let handler = completionHandler {
            self.completionHandlers[addressPattern] = handler
        }
        let message = OSCMessage(with: "\(eosRequestPrefix)\(addressPattern)", arguments: arguments)
        client.send(packet: message)
    }
    
    internal func send(_ packet: OSCPacket) {
        client.send(packet: packet)
    }
    
    // TODO: Not sure this is needed anymore...
    internal func sendMessage(with addressPattern: String, arguments: [Any], completionHandlers: [(addressPattern: String, completionHandler: EosKitCompletionHandler)]) {
        completionHandlers.forEach({ self.completionHandlers[$0.addressPattern] = $0.completionHandler })
        let message = OSCMessage(with: "\(eosRequestPrefix)\(addressPattern)", arguments: arguments)
        client.send(packet: message)
    }
    
}

// MARK:- OSCPacketDestination
extension EosConsole: OSCPacketDestination {
    
    public func take(bundle: OSCBundle) {
        // An eos family console doesn't send any OSC Bundles. It DOES? receive them though!
        return
    }
    
    public func take(message: OSCMessage) {
//        print(OSCAnnotation.annotation(for: message, with: .spaces, andType: true))
        if message.isEosReply {
            let relativeAddress = message.addressWithoutEosReply()
            message.readdress(to: relativeAddress)
            if message.addressPattern.hasPrefix("/get/cue") {
                cuesManager?.take(message: message)
            } else if message.addressPattern.hasPrefix("/get/patch") {
                patchManager?.take(message: message)
            } else {
                guard let completionHandler = completionHandlers[relativeAddress] else { return }
                completionHandlers.removeValue(forKey: relativeAddress)
                completionHandler(message)
            }
        } else {
            delegate?.console(self, didReceiveUndefinedMessage: OSCAnnotation.annotation(for: message, with: .spaces, andType: true))
        }
    }
}

// MARK:- OSCClientDelegate
extension EosConsole: OSCClientDelegate {
    
    public func clientDidConnect(client: OSCClient) {
        state = .connected
        heartbeat(true)
    }
    
    public func clientDidDisconnect(client: OSCClient) {
        state = .disconnected
        heartbeat(false)
        systemFiltersSent = false
        filters.removeAll()
    }
    
}

extension EosConsole {

    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let handler = progressHandler, context == &observationContext && keyPath == "fractionCompleted" {
            let progress = (object as! Progress)
            handler(progress.fractionCompleted, progress.localizedDescription!, progress.localizedAdditionalDescription!)
            if let delegate = delegate, progress.isFinished {
                delegate.console(self, didCompleteSynchronisingOptions: self.options)
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
}
