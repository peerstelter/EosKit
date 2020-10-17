//
//  EosGroupsMessageHandler.swift
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

class EosGroupsMessageHandler {
    
    private let console: EosConsole
    private let database: EosGroupsDatabase
    private var managerProgress: Progress?
    private var groupProgress: Progress?
    
    init(console: EosConsole, database: EosGroupsDatabase, progress: Progress? = nil) {
        self.console = console
        self.database = database
        self.managerProgress = progress
    }
    
    internal func groupCount(message: OSCMessage) -> () {
        guard let count = message.arguments[0] as? Int32 else { return }
        groupProgress = Progress(totalUnitCount: Int64(count))
        managerProgress?.addChild(groupProgress!, withPendingUnitCount: 1)
        for index in 0..<count {
            console.send(OSCMessage.eosGetGroup(with: "\(index)"))
        }
    }
    
    private func group(from message: OSCMessage) -> EosGroup? {
        guard let number = EosGroup.number(from: message), let uNumber = UInt32(number) else { return nil }
        return database.groups.first(where: { $0.number == uNumber })
    }
    
    internal func group(message: OSCMessage) {
//        if let group = group(from: message) {
//            channel.updateNumber(with: message)
//            if let part = part(from: message) {
//                part.updateNumbers(with: message)
//                part.updateWith(message: message)
//            } else {
//                guard let part = EosChannelPart.part(from: message) else { return }
//                channel.parts.insert(part)
//            }
//        } else {
//            guard let channel = EosChannel.channel(from: message), let part = EosChannelPart.part(from: message) else { return }
//            database.add(channel: channel)
//            channel.parts.insert(part)
//        }
    }
    
    internal func groupChannels(message: OSCMessage) {
        
    }
    
}

extension OSCMessage {
    
    // Getting the group count is triggered by the Groups Manager so needs to be internal.
    static internal func eosGetGroupCount() -> OSCMessage {
        return OSCMessage(with: "/eos/get/group/count", arguments: [])
    }
    
    static fileprivate func eosGetGroup(with index: String) -> OSCMessage {
        return OSCMessage(with: "/eos/get/group/index/\(index)", arguments: [])
    }

}
