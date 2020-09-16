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
    
    private let console: EosConsole
    private let database: EosCueDatabase
    
    init(console: EosConsole, database: EosCueDatabase) {
        self.console = console
        self.database = database
    }
    
    internal func cueListCount(message: OSCMessage) -> () {
        guard let count = message.arguments[0] as? Int32 else { return }
        for index in 0..<count {
            console.send(message: OSCMessage.eosGetCueList(with: "\(index)"))
        }
    }
    
    internal func cueList(message: OSCMessage) {
        guard let uuid = uuid(from: message) else { return }
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
        guard let uuid = uuid(from: message) else { return }
        guard let list = database.list(with: uuid) else { return }
        list.updateWithCueListLinks(message: message)
        console.send(message: OSCMessage.eosGetCueCount(for: number))
    }
    
    internal func cueCountForList(message: OSCMessage) {
        guard let count = message.arguments[0] as? Int32 else { return }
        // Check whether we actually have the list in the database before we start getting all of the cues for it.
        // We're checking with database with the Cue List number, which isn't that nice but we don't have the index or UUID in this message.
        guard let number = EosCueList.number(from: message), let uNumber = UInt32(number), let list = database.list(with: uNumber) else { return }
        for index in 0..<count {
            console.send(message: OSCMessage.eosGetCue(with: "\(list.number)", andIndex: "\(index)"))
        }
    }
    
    internal func cue(message: OSCMessage) {
        guard let number = EosCueList.number(from: message), let uNumber = UInt32(number) else { return }
        guard let uuid = uuid(from: message) else { return }
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
        guard let uuid = uuid(from: message) else { return nil }
        return database.cue(with: uuid, inListWithNumber: uNumber)
    }
    
    internal func cueEffects(message: OSCMessage) {
        guard let cue = cue(from: message) else { return }
        cue.updateWithEffects(message: message)
    }
    
    internal func cueLinks(message: OSCMessage) {
        guard let cue = cue(from: message) else { return }
        cue.updateWithLinks(message: message)
    }
    
    internal func cueActions(message: OSCMessage) {
        guard let cue = cue(from: message) else { return }
        cue.updateWithActions(message: message)
        console.send(message: OSCMessage.eosGetPartCount(for: "\(cue.listNumber)", andCue: "\(cue.number)"))
    }
    
    internal func partCountForCue(message: OSCMessage) {
        guard let count = message.arguments[0] as? Int32 else { return }
        for index in 0..<count where count > 0 {
            guard let listNumber = EosCueList.number(from: message) else { return }
            guard let cueNumber = EosCue.number(from: message) else { return }
            console.send(message: OSCMessage.eosGetPart(with: listNumber, cue: cueNumber, andIndex: "\(index)"))
        }
    }
    
    internal func part(message: OSCMessage) {
        guard let listNumber = EosCueList.number(from: message), let uListNumber = UInt32(listNumber) else { return }
        guard let cueNumber = EosCue.number(from: message), let dCueNumber = Double(cueNumber) else { return }
        guard let uuid = uuid(from: message) else { return }
        if let part = database.part(with: uuid, inCueWithNumber: dCueNumber, inListWithNumber: uListNumber) {
            part.updateWith(message: message)
            part.updateNumbers(with: message)
        } else {
            guard let part = EosCuePart.part(from: message) else { return }
            let success = database.add(part: part, toCueWithNumber: dCueNumber, inListWithNumber: uListNumber)
            if !success {
                // TODO: Maybe use Result type with different errors?
                print("Couldn't find list for cue to be added to.")
            }
        }
    }
    
    internal func partEffects(message: OSCMessage) {
        print("Receiving PE: \(OSCAnnotation.annotation(for: message, with: .spaces, andType: false))")
    }
    
    internal func partLinks(message: OSCMessage) {
        print("Receiving PL: \(OSCAnnotation.annotation(for: message, with: .spaces, andType: false))")
    }
    
    internal func partActions(message: OSCMessage) {
        print("Receiving PA: \(OSCAnnotation.annotation(for: message, with: .spaces, andType: false))")
    }
    
    private func uuid(from message: OSCMessage) -> UUID? {
        guard  message.arguments.count >= 2 else { return nil }
        guard let uid = message.arguments[1] as? String, let uuid = UUID(uuidString: uid) else { return nil }
        return uuid
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
        return OSCMessage(with: "/eos/get/cue/\(list)/noparts/count", arguments: [])
    }
    
    static fileprivate func eosGetCue(with list: String, andIndex index: String) -> OSCMessage {
        return OSCMessage(with: "/eos/get/cue/\(list)/noparts/index/\(index)", arguments: [])
    }
    
    static fileprivate func eosGetPartCount(for list: String, andCue cue: String) -> OSCMessage {
        return OSCMessage(with: "/eos/get/cue/\(list)/\(cue)/count", arguments: [])
    }
    
    static fileprivate func eosGetPart(with list:String, cue: String, andIndex index: String) -> OSCMessage {
        return OSCMessage(with: "/eos/get/cue/\(list)/\(cue)/index/\(index)", arguments: [])
    }

}
