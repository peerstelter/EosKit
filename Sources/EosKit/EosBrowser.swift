//
//  EosBrowser.swift
//  EosKit
//
//  Created by Sam Smallman on 12/05/2020.
//  Copyright © 2020 Sam Smallman. https://github.com/SammyTheHand
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
    func browser(_: EosBrowser, didFindConsole console: EosConsole)
}

public final class EosBrowser {
    
    private lazy var request = OSCMessage(messageWithAddressPattern: requestAddressPattern, arguments: [port, name])
    private var clients: [OSCClient] = []
    private let server = OSCServer()
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
        server.port = port
        if let interfaces = interfaces, !interfaces.isEmpty {
            // Create OSCClients for each given interface.
            for interface in Interface.allInterfaces() where interface.broadcastAddress != nil && interface.family == .ipv4 {
                if let address = interface.address, interfaces.contains(address) {
                    clients.append(client(with: interface))
                    continue
                }
                if interfaces.contains(interface.name) {
                    clients.append(client(with: interface))
                    continue
                }
            }
        } else {
            // Create OSCClients for all available interfaces.
            for interface in Interface.allInterfaces() where interface.broadcastAddress != nil && interface.family == .ipv4 {
                clients.append(client(with: interface))
            }
        }
    }
    
    deinit {
        stop()
    }
    
    public func start() {
        server.delegate = self
        do {
            try server.startListening()
        } catch let error as NSError {
            print(error)
        }
        refresh(every: 3)
    }
    
    public func stop() {
        server.stopListening()
        server.delegate = nil
        stopRefreshTimer()
        clients.removeAll()
    }
    
    @objc func requestConsole(timer: Timer) {
        guard let rTimer = refreshTimer, timer == rTimer, rTimer.isValid else { return }
        clients.forEach({ $0.send(packet: request) })
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
    
}

extension EosBrowser: OSCPacketDestination {
    
    public func take(message: OSCMessage) {
        guard message.addressPattern == replyAddressPattern, message.arguments.count == 2 else { return }
        // Get the consoles receive port.
        guard let consolePort = message.arguments[0] as? NSNumber else { return }
        // Get the consoles name and type.
        guard let details = message.arguments[1] as? String else { return }
        // Console name and type are received within the same argument string e.g. "iMac (ETCnomad)" or "RPU3 (Eos RPU)".
        let typeWithBrackets = details[details.lastIndex(of: "(")!...details.lastIndex(of: ")")!]
        let nameWithSpace = details[details.startIndex..<typeWithBrackets.startIndex]
        // Remove the space at the end.
        let name = String(nameWithSpace.dropLast())
        // Remove the brackets.
        let typeString = String(typeWithBrackets.dropFirst().dropLast())
        let type = EosConsole.ConsoleType(rawValue: typeString) ?? .unknown
        
        let console = EosConsole(name: name, type: type, port: UInt16(exactly: consolePort) ?? 3032)
        delegate?.browser(self, didFindConsole: console)
    }
    
    public func take(bundle: OSCBundle) {
        print(bundle.elements.count)
    }
    
}
