//
//  EosFinder.swift
//  EosKit
//
//  Created by Sam Smallman on 21/04/2021.
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
import NetUtils

public final class EosFinder: EosConsoleDiscoverer {
    
    private lazy var request = OSCMessage(with: eosDiscoveryRequest, arguments: [port, name])
    private var console: EosConsole?
    private var discoveryTimer: Timer?
    private var heartbeat: Timer?
    public let port: UInt16
    public let name: String
    
    private let client = OSCClient()
    private let server = OSCServer()
    private (set) var isListening: Bool = false
    
    public var delegate: EosConsoleDiscovererDelegate?
    
    /// A finder able to discover an Eos console on a single network interface.
    ///
    /// - Parameter name: A name for the finder that will show in Eos' diagnostics (Tab 99).
    /// - Parameter port: The port Eos console should reply to.
    public init(name: String = "EosKit Finder", port: UInt16 = 3035) {
        self.name = name
        self.port = port
        client.port = 3034
        server.port = port
        server.reusePort = true
    }
    
    deinit {
        stop()
    }
    
    /// Start the server listening for Eos console discovery responses.
    private func start() {
        server.delegate = self
        do {
            try server.startListening()
            isListening = true
        } catch let error as NSError {
            print(error)
        }
    }
    
    /// Stop the browser from discovering new Eos consoles.
    public func stop() {
        server.stopListening()
        server.delegate = nil
        isListening = false
    }
    
    private func stopDiscoveryTimer() {
        discoveryTimer?.invalidate()
        discoveryTimer = nil
    }
    
    public func find(with interface: Interface? = nil, host: String) {
        if let console = console {
            delegate?.discoverer(self, didLoseConsole: console)
            self.console = nil
        }
        stopDiscoveryTimer()
        heartbeat?.invalidate()
        heartbeat = nil
        if isListening == false {
            start()
        }
        client.interface = interface?.name
        client.host = host
        client.send(packet: request)
        refresh(every: 3)
    }
    
    @objc func requestConsole(timer: Timer) {
        guard let rTimer = discoveryTimer, timer == rTimer, rTimer.isValid else { return }
        client.send(packet: request)
    }
    
    private func refresh(every timeInterval: TimeInterval) {
        if discoveryTimer == nil {
            discoveryTimer = Timer(timeInterval: timeInterval, target: self, selector: #selector(requestConsole(timer:)), userInfo: nil, repeats: true)
            discoveryTimer!.tolerance = timeInterval * 0.1
            RunLoop.current.add(discoveryTimer!, forMode: .common)
        }
    }
    
    /// The console name and type returned from an Eos OSC discovery reply e.g. `/etc/discovery/reply is 3032(i) "RPU3 (Eos RPU)"(s)`
    ///
    /// - Returns: `(name: String, type: EosConsoleType)` or `nil` if the message does not contain more than one argument and the second isn't a `String`.
    private func nameAndType(from message: OSCMessage) -> (name: String, type: EosConsoleType)? {
        guard message.arguments.count > 1, let details = message.arguments[1] as? String else { return nil }
        // TODO: - Run a regex on the string to check for correct formatting.
        // Console name and type are received within the same argument string e.g. "iMac (ETCnomad)" or "RPU3 (Eos RPU)".
        let typeWithBrackets = details[details.lastIndex(of: "(")!...details.lastIndex(of: ")")!]
        let nameWithSpace = details[details.startIndex..<typeWithBrackets.startIndex]
        // Remove the space at the end.
        let name = String(nameWithSpace.dropLast())
        // Remove the brackets.
        let typeString = String(typeWithBrackets.dropFirst().dropLast())
        let type = EosConsoleType(rawValue: typeString) ?? .unknown
        return (name: name, type: type)
    }
    
    @objc func heartbeatTimeout(timer: Timer) {
        guard timer.isValid, let userInfo = timer.userInfo as? [String: String] else { return }
        timer.invalidate()
        let interface = userInfo["interface", default: ""]
        let host = userInfo["host", default: ""]
        guard let console = console, console.host == host, console.interface == interface else { return }
        self.console = nil
        delegate?.discoverer(self, didLoseConsole: console)
    }
        
}

extension EosFinder: OSCPacketDestination {
    
    public func take(message: OSCMessage) {
        guard message.addressPattern == eosDiscoveryReply, let interface = message.replySocket?.interface, let host = message.replySocket?.host, message.arguments.count >= 2 else { return }
        if let console = console, console.host == host {
            // MARK: Console Still Online
            heartbeat?.invalidate()
            heartbeat = Timer(timeInterval: 5, target: self, selector: #selector(heartbeatTimeout(timer:)), userInfo: ["host" : host], repeats: false)
            RunLoop.current.add(heartbeat!, forMode: .common)
        } else {
            // MARK: New Console Found
            // Get the receive port from the message. This will most likely be 3032.
            guard let consolePort = message.arguments[0] as? NSNumber, let port = UInt16(exactly: consolePort) else { return }
            // Get the name and console type from the message.
            guard let nameAndType = nameAndType(from: message) else { return }
            let console = EosConsole(name: nameAndType.name, type: nameAndType.type, interface: interface, host: host, port: port)
            heartbeat = Timer(timeInterval: 5, target: self, selector: #selector(heartbeatTimeout(timer:)), userInfo: ["interface": interface, "host" : host], repeats: false)
            RunLoop.current.add(heartbeat!, forMode: .common)
            self.console = console
            delegate?.discoverer(self, didFindConsole: console)
        }
    }
    
    public func take(bundle: OSCBundle) {
        // An eos family console doesn't send any OSC Bundles.
        return
    }
    
}
