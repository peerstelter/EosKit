//
//  EosGroup.swift
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

class EosGroup: Hashable {
    
    static func == (lhs: EosGroup, rhs: EosGroup) -> Bool {
        return lhs.number == rhs.number
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(number)
    }
    
    let uuid: UUID      // Should never change.
    var number: UInt32
    var label: String
    var channels: [UInt32] = []
    
    init(uuid: UUID, number: UInt32, label: String) {
        self.uuid = uuid
        self.number = number
        self.label = label
    }
    
    internal static func group(from message: OSCMessage) -> EosGroup? {
        guard let number = EosGroup.number(from: message), let uNumber = UInt32(number) else { return nil }
        guard let uid = message.arguments[1] as? String, let uuid = UUID(uuidString: uid) else { return nil }
        guard let label = message.arguments[2] as? String else { return nil }
        return EosGroup(uuid: uuid, number: uNumber, label: label)
    }
    
    internal static func number(from message: OSCMessage) -> String? {
        guard message.addressParts.count > 3 else { return nil }
        return message.addressParts[2]
    }
    
    internal func updateWithChannels(message: OSCMessage) {

    }
    
}
