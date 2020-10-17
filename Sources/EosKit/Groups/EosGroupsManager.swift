//
//  EosGroupsManager.swift
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

import Foundation
import OSCKit

internal final class EosGroupsManager: EosOptionManagerProtocol {
    
    private let console: EosConsole
    internal let addressSpace = OSCAddressSpace()
    private let database: EosGroupsDatabase
    private let handler: EosGroupsMessageHandler
    
    init(console: EosConsole, progress: Progress? = nil) {
        self.console = console
        self.database = EosGroupsDatabase()
        self.handler = EosGroupsMessageHandler(console: console, database: self.database, progress: progress)
        registerAddressSpace()
    }
    
    private func registerAddressSpace() {
        let groupCountMethod = OSCAddressMethod(with: "/get/group/count", andCompletionHandler: handler.groupCount(message:))
        addressSpace.methods.insert(groupCountMethod)
        let groupMethod = OSCAddressMethod(with: "/get/group/*/list/*/*", andCompletionHandler: handler.group(message:))
        addressSpace.methods.insert(groupMethod)
        let groupChannelsMethod = OSCAddressMethod(with: "/get/group/*/channels/list/*/*", andCompletionHandler: handler.groupChannels(message:))
        addressSpace.methods.insert(groupChannelsMethod)
    }
    
    func synchronise() {
        console.send(OSCMessage.eosGetGroupCount())
    }
    
}
