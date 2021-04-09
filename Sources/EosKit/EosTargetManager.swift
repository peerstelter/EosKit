//
//  EosTargetManager.swift
//  EosKit
//
//  Created by Sam Smallman on 06/04/2021.
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
    
    public var database = Set<T>()
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
            } else if $0.hasPrefix("/notify") {
                addressSpace.methods.insert(OSCAddressMethod(with: $0, andCompletionHandler: notify(message:)))
            } else {
                addressSpace.methods.insert(OSCAddressMethod(with: $0, andCompletionHandler: index(message:)))
            }
        }
    }
    
    private func count(message: OSCMessage) -> () {
        guard let count = message.arguments[0] as? Int32, count > 0 else {
            managerProgress?.completedUnitCount = 1
            return
        }
        progress = Progress(totalUnitCount: Int64(count))
        managerProgress?.addChild(progress!, withPendingUnitCount: 1)
        for index in 0..<count {
            console.send(OSCMessage.get(target: T.target, withIndex: index))
        }
    }
    
    private func index(message: OSCMessage) {
        guard let number = message.number() else { return }
        if number == "0" {
            // The EosConsole has been notified of a change to a target and details have
            // been requested using the uuid for a target that does not exist anymore.
            if let uuid = message.uuid(), let target = database.first(where: { $0.uuid == uuid }) {
                database.remove(target)
                messages[uuid] = nil
            }
        } else if message.arguments.isEmpty {
            // The EosConsole has been notified of a change to a target and details have been requested using the number
            // for a target that does not exist anymore. The likelihood of receiving this message is very low as all
            // requests for detailed information use either the index number provided by the count method, or the
            // uuid directly associated with the target in the database. The only time you would see this called
            // would be when a target has been deleted and detailed information has been requested using the
            // old target number... which we don't do.
            if let doubleNumber = Double(number), let target = database.first(where: { $0.number == doubleNumber }) {
                database.remove(target)
                messages[target.uuid] = nil
            }
        } else {
            guard let uuid = message.uuid() else { return }
            if let targetMessage = messages[uuid], targetMessage.first?.number() == number {
                messages[uuid]?.append(message)
            } else {
                messages[uuid] = [message]
            }
            if let targetMessages = messages[uuid], targetMessages.count == T.stepCount {
                if let target = T(messages: targetMessages) {
                    if let index = database.firstIndex(where: { $0.uuid == target.uuid }) {
                        database.remove(at: index)
                    }
                    database.insert(target)
                    // TODO: This function gets called triggered via a notify message which isnt part of the synchronise proceedure...
                    // Do we need to query whether we are currently synchronising?
                    progress?.completedUnitCount += 1
                }
                messages[uuid] = nil
            }
        }
    }
    
    private func notify(message: OSCMessage) {
        var targetList: Set<Double> = []
        for argument in message.arguments[1...] where message.arguments.count >= 2 {
            targetList = targetList.union(EosOSCNumber.doubles(from: argument))
        }
        for targetNumber in targetList {
            if let target = database.first(where: { $0.number == targetNumber }) {
                console.send(OSCMessage.get(target: T.target, withUUID: target.uuid))
            } else {
                console.send(OSCMessage.get(target: T.target, withNumber: "\(targetNumber)"))
            }
        }
    }
    
    func synchronise() {
        console.send(OSCMessage.getCount(of: T.target))
    }
    
}
