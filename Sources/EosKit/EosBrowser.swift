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
    
    private lazy var request = OSCMessage(with: requestAddressPattern, arguments: [port, name])
    private var servers: [(server: OSCServer, client: OSCClient)] = []
    private var consoles: [String: [(console: EosConsole, heartbeat: Timer)]] = [:]
    private var refreshTimer: Timer?
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
                    servers.append((server: server(with: interface, port: port), client: client(with: interface)))
                    continue
                }
                if interfaces.contains(interface.name) {
                    servers.append((server: server(with: interface, port: port), client: client(with: interface)))
                    continue
                }
            }
        } else {
            // Create an OSCClient and an OSCServer for each available interface.
            for interface in Interface.allInterfaces() where interface.broadcastAddress != nil && interface.family == .ipv4 {
                servers.append((server: server(with: interface, port: port), client: client(with: interface)))
            }
        }
    }
    
    deinit {
        stop()
        servers.forEach({
            $0.client.delegate = nil
            $0.server.delegate = nil
        })
        servers.removeAll()
    }
    
    /// Start the browser discovering new Eos consoles.
    public func start() {
        servers.forEach({
            $0.server.delegate = self
            do {
                try $0.server.startListening()
            } catch let error as NSError {
                print(error)
            }
        })
        refresh(every: 3)
    }
    
    /// Stop the browser from discovering new Eos consoles.
    public func stop() {
        servers.forEach({
            $0.server.stopListening()
            $0.server.delegate = nil
        })
        stopRefreshTimer()
    }
    
    @objc func requestConsole(timer: Timer) {
        guard let rTimer = refreshTimer, timer == rTimer, rTimer.isValid else { return }
        servers.forEach({ $0.client.send(packet: request) })
    }
    
    private func refresh(every timeInterval: TimeInterval) {
        if refreshTimer == nil {
            refreshTimer = Timer(timeInterval: timeInterval, target: self, selector: #selector(requestConsole(timer:)), userInfo: nil, repeats: true)
            refreshTimer!.tolerance = timeInterval * 0.1
            RunLoop.current.add(refreshTimer!, forMode: .common)
        }
    }
    
    private func stopRefreshTimer() {
        refreshTimer?.invalidate()
        refreshTimer = nil
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
    
    /// Creates an `OSCServer` configured to receive broadcast discovery responses messages on a given interface and port.
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
    
    private func nameAndType(from message: OSCMessage) -> (name: String, type: EosConsoleType)? {
        guard let details = message.arguments[1] as? String else { return nil }
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
        // The connection could have disconnected whilst waiting for a response.
        guard timer.isValid else { return }
        
    }
        
}

extension EosBrowser: OSCPacketDestination {
    
    public func take(message: OSCMessage) {
        print(message.addressPattern)
        guard message.addressPattern == replyAddressPattern, let interface = message.replySocket?.interface, let host = message.replySocket?.host, message.arguments.count == 2 else { return }
        if let foundConsoles = consoles[interface], foundConsoles.contains(where: { $0.console.host == host }) {
            print("not new console")
        } else {
            // MARK: New Console Found
            
            // Get the receive port from the message. This will most likely be 3032.
            guard let consolePort = message.arguments[0] as? NSNumber, let port = UInt16(exactly: consolePort) else { return }

            // Get the name and console type from the message.
            guard let nameAndType = nameAndType(from: message) else { return }
            
            let console = EosConsole(name: nameAndType.name, type: nameAndType.type, interface: interface, host: host, port: port)
            
            let heartbeat = Timer(timeInterval: EosConsoleHeartbeatFailureInterval, target: self, selector: #selector(heartbeatTimeout(timer:)), userInfo: nil, repeats: false)
//            RunLoop.current.add(heartbeat, forMode: .common)
            
            if var interfacesConsoles = consoles[interface] {
                interfacesConsoles.append((console: console, heartbeat: heartbeat))
            } else {
                consoles[interface] = [(console: console, heartbeat: heartbeat)]
            }
            
            delegate?.browser(self, didFindConsole: console)
        }
        
    }
    
    public func take(bundle: OSCBundle) {
        print(bundle.elements.count)
    }
    
}
