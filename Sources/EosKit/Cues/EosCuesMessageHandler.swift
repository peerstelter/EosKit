//
//  EosCuesMessageHandler.swift
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

class EosCuesMessageHandler {
    
    private enum CueType {
        case cue
        case part
    }
    
    private let console: EosConsole
    private let database: EosCueDatabase
    private var managerProgress: Progress?
    private var listProgress: Progress?
    private var cueProgresses: [UInt32 : Progress] = [:]
    
    init(console: EosConsole, database: EosCueDatabase, progress: Progress? = nil) {
        self.console = console
        self.database = database
        self.managerProgress = progress
    }
    
    internal func cueListCount(message: OSCMessage) -> () {
        guard let count = message.arguments[0] as? Int32 else { return }
//        print("-- \(count)  Lists ---")
        cueProgresses.removeAll()
        listProgress = Progress(totalUnitCount: Int64(count))
        managerProgress?.addChild(listProgress!, withPendingUnitCount: 1)
        
        // Sending as OSCBundle
//        let messages = (0..<count).map { OSCMessage.eosGetCueList(with: "\($0)") }
//        let bundle = OSCBundle(with: messages)
//        console.send(bundle)
        
        // Sending as individual OSCMessages
        for index in 0..<count {
            console.send(OSCMessage.eosGetCueList(with: "\(index)"))
        }
    }
    
    internal func cueList(message: OSCMessage) {
        guard let uuid = message.uuid() else { return }
        if let list = database.list(with: uuid) {
            list.updateWithCueList(message: message)
        } else {
            guard let list = EosCueList.list(from: message) else { return }
            database.add(list: list)
        }
    }
    
    internal func cueListLinks(message: OSCMessage) {
        // Check whether we actually have the list in the database before we attempt to update it or start getting its cues.
        guard let number = EosCueList.number(from: message) else { return }
        guard let uuid = message.uuid() else { return }
        guard let list = database.list(with: uuid) else { return }
        list.updateWithCueListLinks(message: message)
        console.send(OSCMessage.eosGetCueCount(for: number)) // <- No Parts?
    }
    
    internal func cueCountForList(message: OSCMessage) {
        guard let count = message.arguments[0] as? Int32 else { return }
        // Check whether we actually have the list in the database before we start getting all of the cues for it.
        // We're checking with database with the Cue List number, which isn't that nice but we don't have the index or UUID in this message.
        guard let number = EosCueList.number(from: message), let uNumber = UInt32(number), let list = database.list(with: uNumber) else { return }
        let cueProgress = Progress(totalUnitCount: Int64(count))
        cueProgresses[uNumber] = cueProgress
        listProgress?.addChild(cueProgress, withPendingUnitCount: 1)
        
        // Sending as OSCBundle
//        let messages = (0..<count).map { OSCMessage.eosGetCue(with: "\(list.number)", andIndex: "\($0)") }
//        let bundle = OSCBundle(with: messages)
//        console.send(bundle)
        
        
        // Sending as individual OSCMessages
        for index in 0..<count {
            console.send(OSCMessage.eosGetCue(with: "\(list.number)", andIndex: "\(index)"))
        }
    }
    
    internal func cueCountForListNoParts(message: OSCMessage) {
        guard let count = message.arguments[0] as? Int32 else { return }
        // Check whether we actually have the list in the database before we start getting all of the cues for it.
        // We're checking with database with the Cue List number, which isn't that nice but we don't have the index or UUID in this message.
        guard let number = EosCueList.number(from: message), let uNumber = UInt32(number), let list = database.list(with: uNumber) else { return }
//        print("Receiving Cue Count \(count) for List \(list.number) (No Parts)")
        for index in 0..<count {
//            print("Sending Get Cue \(index) for List \(list.number) (No Parts)")
            console.send(OSCMessage.eosGetCueNoParts(with: "\(list.number)", andIndex: "\(index)"))
        }
    }
    
    private func type(for message: OSCMessage) -> CueType? {
        guard message.addressParts.count > 5 else { return nil }
        guard let type = UInt32(message.addressParts[4]) else { return nil }
        if type == 0 {
            return .cue
        } else {
            return .part
        }
    }
    
    internal func cue(message: OSCMessage) {
        guard let number = EosCueList.number(from: message), let uNumber = UInt32(number) else { return }
        guard let uuid = message.uuid() else { return }
        switch type(for: message) {
        case .cue:
            if let cue = database.cue(with: uuid, inListWithNumber: uNumber) {
                cue.updateWith(message: message)
                cue.updateNumbers(with: message)
                OSCMessage.update(&cue.partCount, withArgument: message.arguments[26])
            } else {
                guard let cue = EosCue.cue(from: message) else { return }
                let success = database.add(cue: cue, toListWithNumber: uNumber)
                if !success {
                    // TODO: Maybe use Result type with different errors?
                    print("Couldn't find list for cue to be added to.")
                }
            }
        case .part:
            part(message: message)
        default: return
        }
        guard let cueProgress = cueProgresses[uNumber] else { return }
        var currentProgress = cueProgress.completedUnitCount
        currentProgress += 1
        cueProgress.completedUnitCount = currentProgress
    }
    
    internal func cueNoParts(message: OSCMessage) {
        guard let number = EosCueList.number(from: message), let uNumber = UInt32(number) else { return }
        guard let uuid = message.uuid() else { return }
        if let cue = database.cue(with: uuid, inListWithNumber: uNumber) {
            cue.updateWith(message: message)
            cue.updateNumbers(with: message)
            OSCMessage.update(&cue.partCount, withArgument: message.arguments[26])
        } else {
            guard let cue = EosCue.cue(from: message) else { return }
            let success = database.add(cue: cue, toListWithNumber: uNumber)
            if !success {
                // TODO: Maybe use Result type with different errors?
                print("Couldn't find list for cue to be added to.")
            }
        }
    }
    
    private func cue(from message: OSCMessage) -> EosCue? {
        guard let number = EosCueList.number(from: message), let uNumber = UInt32(number) else { return nil }
        guard let uuid = message.uuid() else { return nil }
        return database.cue(with: uuid, inListWithNumber: uNumber)
    }
    
    internal func cueEffects(message: OSCMessage) {
        switch type(for: message) {
        case .cue:
            guard let cue = cue(from: message) else { return }
            cue.updateWithEffects(message: message)
        case .part:
            partEffects(message: message)
        default: return
        }
    }
    
    internal func cueLinks(message: OSCMessage) {
        switch type(for: message) {
        case .cue:
            guard let cue = cue(from: message) else { return }
            cue.updateWithLinks(message: message)
        case .part:
            partLinks(message: message)
        default: return
        }
    }
    
    internal func cueActions(message: OSCMessage) {
        switch type(for: message) {
        case .cue:
            guard let cue = cue(from: message) else { return }
            cue.updateWithActions(message: message)
        case .part:
            partActions(message: message)
        default: return
        }
    }
    
    internal func partCountForCue(message: OSCMessage) {
        guard let count = message.arguments[0] as? Int32 else { return }
        guard let listNumber = EosCueList.number(from: message) else { return }
        guard let cueNumber = EosCue.number(from: message) else { return }
        let list = database.lists.first(where: { $0.number == UInt32(listNumber)! })
        let cue = list!.cues.first(where: { $0.number == Double(cueNumber)! })
//        print("Receiving Part count \(count) for Cue \(cue!.number) in List \(list!.number)")
        for index in 0..<count where count > 0 {
//            print("Sending get Part \(index) for Cue \(cue!.number) in List \(list!.number)")
            console.send(OSCMessage.eosGetPart(with: listNumber, cue: cueNumber, andIndex: "\(index)"))
        }
    }
    
    internal func part(message: OSCMessage) {
        guard let listNumber = EosCueList.number(from: message), let uListNumber = UInt32(listNumber) else { return }
        guard let cueNumber = EosCue.number(from: message), let dCueNumber = Double(cueNumber) else { return }
        guard let uuid = message.uuid() else { return }
        if let part = database.part(with: uuid, inCueWithNumber: dCueNumber, inListWithNumber: uListNumber) {
            part.updateWith(message: message)
            part.updateNumbers(with: message)
        } else {
            guard let part = EosCuePart.part(from: message) else { return }
            let success = database.add(part: part, toCueWithNumber: dCueNumber, inListWithNumber: uListNumber)
            if !success {
                // TODO: Maybe use Result type with different errors?
                print("Couldn't find list or cue for part to be added to.")
            }
        }
    }
    
    private func part(from message: OSCMessage) -> EosCuePart? {
        guard let listNumber = EosCueList.number(from: message), let uListNumber = UInt32(listNumber) else { return nil }
        guard let cueNumber = EosCue.number(from: message), let dCueNumber = Double(cueNumber) else { return nil }
        guard let uuid = message.uuid() else { return nil }
        return database.part(with: uuid, inCueWithNumber: dCueNumber, inListWithNumber: uListNumber)
    }
    
    internal func partEffects(message: OSCMessage) {
        guard let part = part(from: message) else { return }
        part.updateWithEffects(message: message)
    }
    
    internal func partLinks(message: OSCMessage) {
        guard let part = part(from: message) else { return }
        part.updateWithLinks(message: message)
    }
    
    internal func partActions(message: OSCMessage) {
        guard let part = part(from: message) else { return }
        part.updateWithActions(message: message)
    }

}

extension OSCMessage {
    
    // Getting the cue list count is triggered by the Cues Manager so needs to be internal.
    static internal func eosGetCueListCount() -> OSCMessage {
        return OSCMessage(with: "/eos/get/cuelist/count", arguments: [])
    }
    
    static fileprivate func eosGetCueList(with index: String) -> OSCMessage {
        return OSCMessage(with: "/eos/get/cuelist/index/\(index)", arguments: [])
    }
    
    static fileprivate func eosGetCueCount(for list: String) -> OSCMessage {
        return OSCMessage(with: "/eos/get/cue/\(list)/count", arguments: [])
    }
    
    static fileprivate func eosGetCueCountNoParts(for list: String) -> OSCMessage {
        return OSCMessage(with: "/eos/get/cue/\(list)/noparts/count", arguments: [])
    }
    
    static fileprivate func eosGetCue(with list: String, andIndex index: String) -> OSCMessage {
        return OSCMessage(with: "/eos/get/cue/\(list)/index/\(index)", arguments: [])
    }
    
    static fileprivate func eosGetCueNoParts(with list: String, andIndex index: String) -> OSCMessage {
        return OSCMessage(with: "/eos/get/cue/\(list)/noparts/index/\(index)", arguments: [])
    }
    
    static fileprivate func eosGetPartCount(for list: String, andCue cue: String) -> OSCMessage {
        return OSCMessage(with: "/eos/get/cue/\(list)/\(cue)/count", arguments: [])
    }
    
    static fileprivate func eosGetPart(with list:String, cue: String, andIndex index: String) -> OSCMessage {
        return OSCMessage(with: "/eos/get/cue/\(list)/\(cue)/index/\(index)", arguments: [])
    }

}
