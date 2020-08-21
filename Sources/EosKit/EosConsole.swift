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
import CoreBluetooth

public protocol EosConsoleDelegate {
    func console(_ console: EosConsole, didUpdateState state: EosConsoleState)
    func console(_ console: EosConsole, didReceiveUndefinedMessage message: String)
}

/// Represents the current state of an EosConsole.
/// - Note:
public enum EosConsoleState : Int {
    case unknown = 0
    case disconnected = 1
    case connected = 2
    case unresponsive = 3
    case responsive = 4
}

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

public final class EosConsole: NSObject {
    
    /// The current state of the console.
    ///
    /// This state is initially set to `EosConsoleState.unknown`. When the state updates, the console calls its delegate's console(_ console: `EosConsole`, didUpdateState state: `EosConsoleState`) method.
    private(set) public var state: EosConsoleState = .unknown { didSet { delegate?.console(self, didUpdateState: state) }}
    
    private var completionHandlers: [String : EosKitCompletionHandler] = [:]
    private let client = OSCClient()
    private let uuid = UUID()
    private var heartbeats = -1 // Not running
    private var heartbeatTimer: Timer?
    
    public let name: String
    public let type: EosConsoleType
    public let interface: String
    public let host: String
    public let port: UInt16 = 3032
    
    public var isConnected: Bool { get { return client.isConnected } }
    public var delegate: EosConsoleDelegate?
    
    public init(name: String, type: EosConsoleType = .unknown, interface: String = "", host: String) {
        self.name = name
        self.type = type
        self.interface = interface
        self.host = host
        client.delegate = self
        client.useTCP = true
        print("Initialised with \(name) : \(type.rawValue) : \(interface) : \(host) : \(port)")
    }
    
    func connect() -> Bool {
        do {
            try client.connect()
            return true
        } catch {
            return false
        }
    }
    
    func disconnect() {
        client.disconnect()
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
        sendMessage(with: pingRequest, arguments:  ["EosKit Heartbeat", uuid.uuidString], completionHandler: { [weak self] data in
            guard let strongSelf = self else { return }
            
            guard strongSelf.heartbeats > -1 else { return }
            strongSelf.clearHeartbeatTimeout()
            guard strongSelf.state != .disconnected && strongSelf.client.isConnected else { return }
            
            strongSelf.perform(#selector(strongSelf.sendHeartbeat), with: nil, afterDelay: EosConsoleHeartbeatInterval)
        })
        
        heartbeatTimer = Timer(timeInterval: EosConsoleHeartbeatFailureInterval, target: self, selector: #selector(heartbeatTimeout(timer:)), userInfo: nil, repeats: false)
        RunLoop.current.add(heartbeatTimer!, forMode: .common)
    }
    
    @objc func heartbeatTimeout(timer: Timer) {
        // The connection could have disconnected whilst waiting for a response.
        guard timer.isValid, heartbeats != -1, state != .disconnected || state != .unknown else { return }
        
        // If the timer fires before we receive a response from the hearbeat and we have attempts left, try sending again.
        if heartbeats < EosConsoleHeartbeatMaxAttempts {
            heartbeats += 1
            sendHeartbeat()
        } else {
//            os_log("No Heartbeat...", log: .timeline, type: .info)
            state = .unresponsive
        }
    }
    
    // Optional parameters within a closure are escaping by default.
    private func sendMessage(with addressPattern: String, arguments: [Any], timeline: Bool = true, completionHandler: EosKitCompletionHandler? = nil) {
        if let handler = completionHandler {
//            os_log("Adding completion handler for: %{PUBLIC}@", log: .client, type: .info, addressPattern)
            self.completionHandlers[addressPattern] = handler
        }
//        let fullAddress = timeline && delegate != nil ? "\(timelinePrefix)\(addressPattern)" : addressPattern
//        let message = OSCMessage(messageWithAddressPattern: fullAddress, arguments: arguments)
//        message.readdress(to: message.addressPattern(withApplication: true))
//
//        if message.addressPattern != "/stamp/timelines" {
//            let annotation = OSCAnnotation.annotation(for: message, with: .spaces, andType: true)
//            os_log("Sent: %{PUBLIC}@", log: .client, type: .info, annotation)
//        }
        client.send(packet: message)
    }
    
}

extension EosConsole: OSCPacketDestination {
    
    public func take(bundle: OSCBundle) {
        // Eos Consoles don't send any OSC Bundles.
        return
    }
    
    public func take(message: OSCMessage) {
        if message.isEosReply {
            if message.isHeartbeat(with: uuid) && state == .unresponsive {
                state = .responsive
            }
        } else {
            delegate?.console(self, didReceiveUndefinedMessage: OSCAnnotation.annotation(for: message, with: .spaces, andType: true))
        }
    }
}

extension EosConsole: OSCClientDelegate {
    
    public func clientDidConnect(client: OSCClient) {
        state = .connected
        heartbeat(true)
    }
    
    public func clientDidDisconnect(client: OSCClient) {
        state = .disconnected
    }
    
}
