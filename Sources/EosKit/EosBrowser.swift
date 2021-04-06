//
//  EosBrowser.swift
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
import NetUtils

public protocol EosBrowserDelegate {
    func browser(_ browser: EosBrowser, didFindConsole console: EosConsole)
    func browser(_ browser: EosBrowser, didLooseConsole console: EosConsole)
}

public final class EosBrowser {
    
    private lazy var request = OSCMessage(with: eosDiscoveryRequest, arguments: [port, name])
    private var discoveringInterfaces: [(server: OSCServer, client: OSCClient)] = []
    private var consoles: [String: [(console: EosConsole, heartbeat: Timer)]] = [:]
    private var discoveryTimer: Timer?
    private let port: UInt16
    private let name: String
    
    public var delegate: EosBrowserDelegate?
    
    /// A browser able to discover Eos consoles on one or more network interfaces.
    ///
    /// - Parameter name: A name for the browser that will show in Eos' diagnostics (Tab 99).
    /// - Parameter port: The port Eos consoles should reply to.
    /// - Parameter interfaces: An array of network interfaces to search for Eos consoles on.
    ///                         An interface may be specified by name (e.g. "en1" or "lo0") or by IP address (e.g. "192.168.4.34").
    ///                         Interfaces can be `nil`, in which case the browser will search on all available network interfaces.
    public init(name: String = "EosKit", port: UInt16 = 3035, interfaces: [String]? = nil) {
        self.name = name
        self.port = port
        if let interfaces = interfaces, !interfaces.isEmpty {
            // Create an OSCClients and an OSCServers for each given interface.
            for interface in Interface.allInterfaces() where interface.broadcastAddress != nil && interface.family == .ipv4 {
                if let address = interface.address, interfaces.contains(address) {
                    discoveringInterfaces.append((server: server(with: interface, port: port), client: client(with: interface)))
                    continue
                }
                if interfaces.contains(interface.name) {
                    discoveringInterfaces.append((server: server(with: interface, port: port), client: client(with: interface)))
                    continue
                }
            }
        } else {
            // Create an OSCClient and an OSCServer for each available interface.
            for interface in Interface.allInterfaces() where interface.broadcastAddress != nil && interface.family == .ipv4 {
                discoveringInterfaces.append((server: server(with: interface, port: port), client: client(with: interface)))
            }
        }
    }
    
    deinit {
        stop()
        discoveringInterfaces.forEach({
            $0.client.disconnect()
            $0.client.delegate = nil
            $0.server.stopListening()
            $0.server.delegate = nil
        })
        discoveringInterfaces.removeAll()
    }
    
    /// Start the browser discovering new Eos consoles.
    public func start() {
        discoveringInterfaces.forEach({
            $0.server.delegate = self
            do {
                try $0.server.startListening()
            } catch let error as NSError {
                print(error)
            }
            $0.client.send(packet: request)
        })
        refresh(every: 3)
    }
    
    /// Stop the browser from discovering new Eos consoles.
    public func stop() {
        discoveringInterfaces.forEach({
            $0.server.stopListening()
            $0.server.delegate = nil
        })
        stopDiscoveryTimer()
    }
    
    @objc func requestConsole(timer: Timer) {
        guard let rTimer = discoveryTimer, timer == rTimer, rTimer.isValid else { return }
        discoveringInterfaces.forEach({ $0.client.send(packet: request) })
    }
    
    private func refresh(every timeInterval: TimeInterval) {
        if discoveryTimer == nil {
            discoveryTimer = Timer(timeInterval: timeInterval, target: self, selector: #selector(requestConsole(timer:)), userInfo: nil, repeats: true)
            discoveryTimer!.tolerance = timeInterval * 0.1
            RunLoop.current.add(discoveryTimer!, forMode: .common)
        }
    }
    
    private func stopDiscoveryTimer() {
        discoveryTimer?.invalidate()
        discoveryTimer = nil
    }
    
    /// Creates an `OSCClient` configured to broadcast discovery request messages on a given interface.
    ///
    /// - Parameter interface:  An Interface the OSC Client will broadcast on.
    private func client(with interface: Interface) -> OSCClient {
        let client = OSCClient()
        client.port = 3034
        client.interface = interface.name
        client.host = interface.broadcastAddress
        return client
    }
    
    /// Creates an `OSCServer` configured to receive broadcast discovery reply messages on a given interface and port.
    ///
    /// - Parameter interface:  An Interface the OSC Server will listen on.
    /// - Parameter port:       The port the server will bind to.
    private func server(with interface: Interface, port: UInt16 = 3035) -> OSCServer {
        let server = OSCServer()
        server.port = port
        server.interface = interface.name
        server.reusePort = true
        return server
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
        guard var foundConsoles = consoles[interface], let index = foundConsoles.firstIndex(where: { $0.console.host == host }) else { return }
        let console = foundConsoles[index].console
        foundConsoles.remove(at: index)
        consoles[interface] = foundConsoles
        print("\(name) Lost Console: \(interface) : \(console.host)")
        delegate?.browser(self, didLooseConsole: console)
    }
        
}

extension EosBrowser: OSCPacketDestination {
    
    public func take(message: OSCMessage) {
//        print(OSCAnnotation.annotation(for: message, with: .spaces, andType: true))
        guard message.addressPattern == eosDiscoveryReply, let interface = message.replySocket?.interface, let host = message.replySocket?.host, message.arguments.count >= 2 else { return }
        if var foundConsoles = consoles[interface], let index = foundConsoles.firstIndex(where: { $0.console.host == host }) {
            // MARK: Console Still Online
//            print("Still Online: \(interface) : \(host)")
            foundConsoles[index].heartbeat.invalidate()
            let heartbeat = Timer(timeInterval: 5, target: self, selector: #selector(heartbeatTimeout(timer:)), userInfo: ["interface": interface, "host" : host], repeats: false)
            foundConsoles[index].heartbeat = heartbeat
            consoles[interface] = foundConsoles
            RunLoop.current.add(heartbeat, forMode: .common)
        } else {
            // MARK: New Console Found
            print("\(name) Found Console: \(interface) : \(host)")
            // Get the receive port from the message. This will most likely be 3032.
            guard let consolePort = message.arguments[0] as? NSNumber, let port = UInt16(exactly: consolePort) else { return }

            // Get the name and console type from the message.
            guard let nameAndType = nameAndType(from: message) else { return }
            
            let console = EosConsole(name: nameAndType.name, type: nameAndType.type, interface: interface, host: host, port: port)
            
            let heartbeat = Timer(timeInterval: 5, target: self, selector: #selector(heartbeatTimeout(timer:)), userInfo: ["interface": interface, "host" : host], repeats: false)
            RunLoop.current.add(heartbeat, forMode: .common)
            
            if var interfacesConsoles = consoles[interface] {
                interfacesConsoles.append((console: console, heartbeat: heartbeat))
                consoles[interface] = interfacesConsoles
            } else {
                consoles[interface] = [(console: console, heartbeat: heartbeat)]
            }
            
            delegate?.browser(self, didFindConsole: console)
        }
        
    }
    
    public func take(bundle: OSCBundle) {
        // An eos family console doesn't send any OSC Bundles. It DOES? receive them though!
        return
    }
    
}
