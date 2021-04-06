//
//  EosTargetManager.swift
//  EosKit
//
//  Created by Sam Smallman on 06/04/2020.
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

internal class EosTargetManager<T: EosTarget>: EosTargetManagerProtocol {
    
    public var database = Set<T>() {
        didSet {
            print(database)
        }
    }
    private let console: EosConsole
    internal let addressSpace = OSCAddressSpace()
    
    private var managerProgress: Progress?
    private var progress: Progress?
    private var messages: [UUID:[OSCMessage]] = [:]
    
    init(console: EosConsole, progress: Progress? = nil) {
        self.console = console
        self.managerProgress = progress
        registerAddressSpace()
    }
    
    private func registerAddressSpace() {
        T.target.filters.forEach {
            if $0.hasSuffix("count") {
                addressSpace.methods.insert(OSCAddressMethod(with: $0, andCompletionHandler: count(message:)))
            } else {
                addressSpace.methods.insert(OSCAddressMethod(with: $0, andCompletionHandler: index(message:)))
            }
        }
    }
    
    func synchronise() {
        console.send(OSCMessage.getCount(for: T.target))
    }
    
    private func count(message: OSCMessage) -> () {
        guard let count = message.arguments[0] as? Int32, count > 0 else {
            managerProgress?.completedUnitCount = 1
            return
        }
        progress = Progress(totalUnitCount: Int64(count))
        managerProgress?.addChild(progress!, withPendingUnitCount: 1)
        for index in 0..<count {
            console.send(OSCMessage.get(index: index, forTarget: T.target))
        }
    }
    
    private func index(message: OSCMessage) {
        guard let uuid = message.uuid(), let number = message.number() else { return }
        if let targetMessage = messages[uuid], targetMessage.first?.number() == number {
            messages[uuid]?.append(message)
        } else {
            messages[uuid] = [message]
        }
        if let targetMessages = messages[uuid], targetMessages.count == T.stepCount {
            if let target = T(messages: targetMessages) {
                database.insert(target)
                progress?.completedUnitCount += 1
            }
            messages[uuid] = nil
        }
    }
    
}
