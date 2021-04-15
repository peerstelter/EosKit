//
//  EosPatchManager.swift
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

internal final class EosPatchManager: EosTargetManagerProtocol {
    
    private let console: EosConsole
    internal let addressSpace = OSCAddressSpace()
    private var database = Set<EosChannel>()
    
    private var managerProgress: Progress?
    private var progress: Progress?
    /// A dictionary of `OSCMessage`'s to build an EosChannel with its component `EosChannelPart`'s.
    ///
    /// - The key of the dictionary is the EosChannel number.
    /// - `count` is the number of parts the channel has.
    /// - `parts` holds the current cached arrays of part messages.
    private var messages: [String:(count: UInt32, parts: [[OSCMessage]])] = [:]
    
    init(console: EosConsole, progress: Progress? = nil) {
        self.console = console
        self.managerProgress = progress
        registerAddressSpace()
    }
    
    private func registerAddressSpace() {
        EosRecordTarget.patch.filters.forEach {
            if $0.hasSuffix("count") {
                addressSpace.methods.insert(OSCAddressMethod(with: $0, andCompletionHandler: count(message:)))
            } else if $0.hasPrefix("/notify") {
                addressSpace.methods.insert(OSCAddressMethod(with: $0, andCompletionHandler: notify(message:)))
            } else {
                addressSpace.methods.insert(OSCAddressMethod(with: $0, andCompletionHandler: index(message:)))
            }
        }
    }
    
    internal func count(message: OSCMessage) -> () {
        guard let count = message.arguments[0] as? Int32 else { return }
        progress = Progress(totalUnitCount: Int64(count))
        managerProgress?.addChild(progress!, withPendingUnitCount: 1)
        for index in 0..<count {
            console.send(OSCMessage.get(target: .patch, withIndex: index))
        }
    }
    
    internal func index(message: OSCMessage) {
        guard let number = message.number(), let subNumber = message.subNumber() else { return }
        if let targetMessage = messages[number], targetMessage.parts.first?.first?.number() == number {
            if let partIndex = targetMessage.parts.firstIndex(where: { $0.contains { $0.subNumber() == subNumber } }) {
                // This will be a notes message
                messages[number]?.parts[partIndex].append(message)
            } else {
                messages[number]?.parts.append([message])
                // TODO: This function gets called via a notify message which isnt part of the synchronise proceedure...
                // Do we need to query whether we are currently synchronising?
                progress?.completedUnitCount += 1
            }
        } else {
            // This gets called once per channel when receiving the first part.
            guard message.addressPattern.hasSuffix("notes") == false,
                  let partCount = message.arguments[19] as? NSNumber,
                  let uPartCount = UInt32(exactly: partCount) else { return }
            messages[number] = (count: uPartCount, parts: [[message]])
            // TODO: This function gets called triggered via a notify message which isnt part of the synchronise proceedure...
            // Do we need to query whether we are currently synchronising?
            progress?.completedUnitCount += 1
        }
        if let targetMessages = messages[number],
           targetMessages.count == targetMessages.parts.count,
           targetMessages.parts.allSatisfy({ $0.count == EosChannelPart.stepCount }),
           let uNumber = UInt32(number)
        {
            database.insert(EosChannel(number: uNumber, parts: targetMessages.parts.compactMap { EosChannelPart(messages: $0) }.sorted(by: { $0.number < $1.number }) ))
            messages[number] = nil
        }
    }
    
    private func notify(message: OSCMessage) {
        synchronise()
    }
    
    func synchronise() {
        messages.removeAll()
        database.removeAll()
        console.send(OSCMessage.getCount(of: .patch))
    }

}
