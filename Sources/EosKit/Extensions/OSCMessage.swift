//
//  OSCMessage.swift
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
//

import Foundation
import OSCKit

extension OSCMessage {
    
    internal class var eosReset: OSCMessage { return Cache.eosReset }
    internal class var eosVersion: OSCMessage { return Cache.eosVersion }
    
    private struct Cache {
        static let eosReset = OSCMessage(with: "/eos/reset", arguments: [])
        static let eosVersion = OSCMessage(with: "/eos/get/version", arguments: [])
    }
    
    internal var isEosReply: Bool { get { self.addressPattern.hasPrefix(eosReplyPrefix) }}
    
    internal func addressWithoutEosReply() -> String {
        let startIndex = self.addressPattern.index(self.addressPattern.startIndex, offsetBy: eosReplyPrefix.count)
        return String(self.addressPattern[startIndex...])
    }
    
    internal func isHeartbeat(with uuid: UUID) -> Bool {
        guard self.addressPattern == eosPingRequest,
              self.arguments.count == 2,
              let argument1 = self.arguments[0] as? String,
              let argument2 = self.arguments[1] as? String else { return false }
        return argument1 == eosHeartbeatString && uuid.uuidString == argument2
    }
    
    internal static func update(_ bool: inout Bool, withArgument argument: Any) {
        if let item = argument as? OSCArgument {
            let boolItem = item == .oscTrue
            if bool != boolItem {
                bool = boolItem
            }
        }
    }
    
    internal static func update(_ int32: inout Int32, withArgument argument: Any) {
        if let item = argument as? Int32, int32 != item {
            int32 = item
        }
    }
    
    internal static func update(_ uint32: inout UInt32, withArgument argument: Any) {
        if let number = argument as? NSNumber, let item = UInt32(exactly: number), uint32 != item {
            uint32 = item
        }
    }
    
    internal static func update(_ string: inout String, withArgument argument: Any) {
        if let item = argument as? String, string != item {
            string = item
        }
    }

}
