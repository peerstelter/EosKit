//
//  MockEosConsoleDelegate.swift
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

internal final class MockEosConsoleDelegate: EosConsoleDelegate {

    internal typealias handler = (EosConsole) -> Void
    
    private let consoleDidConnectCallback: handler?
    private let consoleDidDisconnectCallback: handler?
    
    init(callback: @escaping handler) {
        self.callback = callback
    }
    
    func consoleDidConnect(_ console: EosConsole) {
        if let callback = consoleDidConnectCallback {
            callback(console)
        }
    }
    
    func consoleDidDisconnect(_ console: EosConsole) {
        if let callback = consoleDidConnectCallback {
            callback(console)
        }
    }
    
    func console(_ console: EosConsole, didMakeFirstContact contact: Bool) {
        callback(console)
    }
    
    func consoleDidLooseContact(_ console: EosConsole) {
        callback(console)
    }
    
    func console(_ console: EosConsole, didReceiveUndefinedMessage message: String) {
        callback(console)
    }
    
}
