//
//  EosCueManager.swift
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

internal final class EosCueManager: EosTargetManagerProtocol {
    
    private enum MessageType {
        case list
        case cue
        case part
        
        /// This is a really rough implementation that only accounts for the address patterns defined in the `eosCueNoPartsFilters` array.
        internal static func type(from message: OSCMessage) -> MessageType? {
            if message.addressPattern.hasPrefix("/notify") {
                return nil
            } else if message.addressPattern.contains("cuelist") {
                return MessageType.list
            } else if message.addressPattern.contains("noparts") {
                return MessageType.cue
            } else {
                return MessageType.part
            }
        }
    }
    
    private let console: EosConsole
    internal let addressSpace = OSCAddressSpace()
    private var database: [Double: [EosCue]] = [:] {
        didSet {
            print(database)
        }
    }
    
    /// A dictionary of `OSCMessage`'s to build an EosCue with its component `EosCuePart`'s.
    ///
    /// - The dictionary is keyed by both the cue list and cue number e.g. "1/0.5".
    /// - `cue` holds the current cached cue index messages.
    /// - `count` is the number of parts the cue has.
    /// - `parts` holds the current cached arrays of part index messages.
    private var messages: [String:(cue: [OSCMessage], count: UInt32, parts: [[OSCMessage]])] = [:]
    
    init(console: EosConsole, progress: Progress? = nil) {
        self.console = console
        registerAddressSpace()
    }
    
    private func registerAddressSpace() {
        EosRecordTarget.cue.filters.forEach {
            if $0.hasSuffix("count") {
                addressSpace.methods.insert(OSCAddressMethod(with: $0, andCompletionHandler: count(message:)))
            } else if $0.hasPrefix("/notify") {
                addressSpace.methods.insert(OSCAddressMethod(with: $0, andCompletionHandler: notify(message:)))
            } else {
                addressSpace.methods.insert(OSCAddressMethod(with: $0, andCompletionHandler: index(message:)))
            }
        }
    }
    
    internal func count(message: OSCMessage) {
        guard let count = message.arguments[0] as? Int32, count > 0,
              let messageType = MessageType.type(from: message),
              let number = message.number()
        else { return }
        let cueNumber = message.subNumber() ?? "" // Only used for the getting the part where it should be non nil.
        for index in 0..<count {
            switch messageType {
            case .list:
                console.send(OSCMessage.get(target: EosRecordTarget.cueList, withIndex: index))
            case .cue:
                console.send(OSCMessage.getCueNoPartsIn(list: number, atIndex: index))
            case .part:
                console.send(OSCMessage.getPartFor(cue: cueNumber, inList: number, atIndex: index))
            }
        }
    }
    
    internal func index(message: OSCMessage) {
        guard let number = message.number(), let dNumber = Double(number),
              let messageType = MessageType.type(from: message)
        else { return }
        let cueNumber = message.subNumber() ?? ""
        switch messageType {
        case .list:
            if database.keys.contains(dNumber) == false {
                database[dNumber] = []
            }
            console.send(OSCMessage.getCountOfCuesNoPartsIn(list: number))
        case .cue:
            let key = "\(number)/\(cueNumber)"
            if message.addressParts.count == 8, let partCount = message.arguments[26] as? NSNumber, let uPartCount = UInt32(exactly: partCount) {
                messages[key] = (cue: [message], count: uPartCount, parts: [])
            } else if let _ = messages[key] {
                messages[key]?.cue.append(message)
            }
            if let targetMessages = messages[key], targetMessages.cue.count == EosCue.stepCount {
                if targetMessages.count == 0 {
                    if let cue = EosCue(messages: targetMessages.cue) {
                        guard let list = database[dNumber] else { return }
                        if list.isEmpty {
                            database[dNumber]?.append(cue)
                        } else {
                            if let firstIndex = list.firstIndex(where: { $0.uuid == cue.uuid }) {
                                database[dNumber]?.remove(at: firstIndex)
                            }
                            let index = list.insertionIndex(for: { $0.number < cue.number })
                            database[dNumber]?.insert(cue, at: index)
                        }
                        messages[key] = nil
                    }
                } else {
                    console.send(OSCMessage.getCountOfPartsFor(cue: cueNumber, inList: number))
                }
            }
        case .part:
            let key = "\(number)/\(cueNumber)"
            if let index = messages[key]?.parts.firstIndex(where: { $0.contains(where: { partMessage in
                message.addressParts[4] == partMessage.addressParts[4]
            })}) {
                messages[key]?.parts[index].append(message)
            } else {
                messages[key]?.parts.append([message])
            }
            guard let targetMessages = messages[key] else { return }
            if targetMessages.count == targetMessages.parts.count && targetMessages.parts.allSatisfy( { $0.count == EosCuePart.stepCount }) {
                let parts = targetMessages.parts.compactMap { EosCuePart(messages: $0) }
                guard let cue = EosCue(messages: targetMessages.cue, parts: parts),
                      let list = database[dNumber]
                else { return }
                if list.isEmpty {
                    database[dNumber]?.append(cue)
                } else {
                    if let firstIndex = list.firstIndex(where: { $0.uuid == cue.uuid }) {
                        database[dNumber]?.remove(at: firstIndex)
                    }
                    let index = list.insertionIndex(for: { $0.number < cue.number })
                    database[dNumber]?.insert(cue, at: index)
                }
                messages[key] = nil
            }
        }

    }
    
    internal func notify(message: OSCMessage) {
        guard let number = message.number(),
              let dNumber = Double(number),
              let cueList = database[dNumber]
        else { return }
        var cueNumbers: Set<Double> = []
        for argument in message.arguments[1...] where message.arguments.count >= 2 {
            cueNumbers = cueNumbers.union(EosOSCNumber.doubles(from: argument))
        }
        for cueNumber in cueNumbers {
//            if let target = database[cueList].first(where: { $0.number == cueNumber }) {
//                console.send(OSCMessage.get(target: T.target, withUUID: target.uuid))
//            } else {
//
//                console.send(OSCMessage.get(target: T.target, withNumber: "\(targetNumber)"))
//            }
        }
    }
    
    // MARK:- Sync
    func synchronise() {
        console.send(OSCMessage.getCount(of: EosRecordTarget.cueList))
    }
    
}

extension OSCMessage {

    static fileprivate func getCountOfCuesNoPartsIn(list: String) -> OSCMessage {
        return OSCMessage(with: "/eos/get/cue/\(list)/noparts/count")
    }

    static fileprivate func getCueNoPartsIn(list: String, atIndex index: Int32) -> OSCMessage {
        return OSCMessage(with: "/eos/get/cue/\(list)/noparts/index/\(index)")
    }

    static fileprivate func getCountOfPartsFor(cue: String, inList list: String) -> OSCMessage {
        return OSCMessage(with: "/eos/get/cue/\(list)/\(cue)/count")
    }

    static fileprivate func getPartFor(cue: String, inList list: String, atIndex index: Int32) -> OSCMessage {
        return OSCMessage(with: "/eos/get/cue/\(list)/\(cue)/index/\(index)")
    }

}
