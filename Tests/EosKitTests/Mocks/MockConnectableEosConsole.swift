//
//  MockConnectableEosConsole.swift
//  EosKit
//
//  Created by Sam Smallman on 16/05/2020.
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
import XCTest
import OSCKit
@testable import EosKit

class MockConnectableEosConsole {
    
    private let name: String
    private let type: EosConsole.ConsoleType
    private let port: UInt16
    private let interface: String?
    private let server = OSCServer()
    
    /// A mock console connectable over a network.
    ///
    /// - Parameter name: A name for the console.
    /// - Parameter type: The type of console (e.g. `.eos` or `.ion`).
    /// - Parameter port: The port the mock Eos consoles should be connectable on.
    ///                   Eos consoles can be connected to via TCP on port 3032.
    init(name: String = "EosKit", type: EosConsole.ConsoleType = .eos, port: UInt16 = 3032, interface: String? = nil) {
        self.name = name
        self.type = type
        self.port = port
        server.port = port
        self.interface = interface
        if let i = interface {
            server.interface = i
        }
        server.reusePort = true
        server.delegate = self
    }
    
    public func start() {
        do {
            try server.startListening()
        } catch let error as NSError {
           print(error)
       }
    }
    
    public func stop() {
        server.stopListening()
    }
}

extension MockConnectableEosConsole: OSCPacketDestination {
    
    func take(message: OSCMessage) {
        return
    }
    
    func take(bundle: OSCBundle) {
        print("Received Bundle")
    }
    
}
