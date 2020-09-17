//
//  EosCueList.swift
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

public class EosCueList: Equatable, Hashable {
    
    public static func == (lhs: EosCueList, rhs: EosCueList) -> Bool {
        return lhs.uuid == rhs.uuid
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(uuid)
    }
    
    var description: String { get { return "Cue List \(number)\(!label.isEmpty ? " (\(label)):" : ":") \(!links.isEmpty ? "links: \(links)" : "")\(!cues.isEmpty ? "Cues: \(cues.count)" : "")" } }
    
    var number: UInt32
    let uuid: UUID              // Should never change.
    var label: String
    var playbackMode: String
    var faderMode: String
    var independent: Bool
    var htp: Bool
    var assert: Bool
    var block: Bool
    var background: Bool
    var soloMode: Bool
    var timecodeList: UInt32?
    var oosSync: Bool
    var links: Set<Double> = [] // OSC Number Range - When a range numbers contains 2 or more consecutive whole numbers, they will be represented as strings in the following format: X-Y.
    var cues: Set<EosCue> = []
    
    internal init(number: UInt32, uuid: UUID, label: String, playbackMode: String, faderMode: String, independent: Bool, htp: Bool, assert: Bool, block: Bool, background: Bool, soloMode: Bool, timecodeList: UInt32?, oosSync: Bool) {
        self.number = number
        self.uuid = uuid
        self.label = label
        self.playbackMode = playbackMode
        self.faderMode = faderMode
        self.independent = independent
        self.htp = htp
        self.assert = assert
        self.block = block
        self.background = background
        self.soloMode = soloMode
        self.timecodeList = timecodeList
        self.oosSync = oosSync
    }
    
    static func list(from message: OSCMessage) -> EosCueList? {
        guard message.arguments.count >= 13 else { return nil }
        guard let number = number(from: message), let uNumber = UInt32(number) else { return nil }
        guard let uid = message.arguments[1] as? String, let uuid = UUID(uuidString: uid) else { return nil }
        guard let label = message.arguments[2] as? String else { return nil }
        guard let playbackMode = message.arguments[3] as? String else { return nil }
        guard let faderMode = message.arguments[4] as? String else { return nil }
        guard let independent = message.arguments[5] as? OSCArgument else { return nil }
        guard let htp = message.arguments[6] as? OSCArgument else { return nil }
        guard let assert = message.arguments[7] as? OSCArgument else { return nil }
        guard let block = message.arguments[8] as? OSCArgument else { return nil }
        guard let background = message.arguments[9] as? OSCArgument else { return nil }
        guard let soloMode = message.arguments[10] as? OSCArgument else { return nil }
        guard let timecodeList = message.arguments[11] as? NSNumber else { return nil }
        guard let oosSync = message.arguments[12] as? OSCArgument else { return nil }
        return EosCueList(number: uNumber, uuid: uuid, label: label, playbackMode: playbackMode, faderMode: faderMode, independent: independent == .oscTrue, htp: htp == .oscTrue, assert: assert == .oscTrue, block: block == .oscTrue, background: background == .oscTrue, soloMode: soloMode == .oscTrue, timecodeList: UInt32(exactly: timecodeList), oosSync: oosSync == .oscTrue)
     }
    
    internal static func number(from message: OSCMessage) -> String? {
        guard message.addressParts.count > 3 else { return nil }
        return message.addressParts[2]
    }
    
    internal func updateWithCueList(message: OSCMessage) {
        guard message.arguments.count >= 13 else { return }
        guard let uid = message.arguments[1] as? String, let uuid = UUID(uuidString: uid), self.uuid == uuid else { return }
        if let number = EosCueList.number(from: message), let uNumber = UInt32(number), self.number != uNumber {
            self.number = uNumber
        }
        OSCMessage.update(&label, withArgument: message.arguments[2])
        OSCMessage.update(&playbackMode, withArgument: message.arguments[3])
        OSCMessage.update(&faderMode, withArgument: message.arguments[4])
        OSCMessage.update(&independent, withArgument: message.arguments[5])
        OSCMessage.update(&htp, withArgument: message.arguments[6])
        OSCMessage.update(&assert, withArgument: message.arguments[7])
        OSCMessage.update(&block, withArgument: message.arguments[8])
        OSCMessage.update(&background, withArgument: message.arguments[9])
        OSCMessage.update(&soloMode, withArgument: message.arguments[10])
        if let timecodeList = message.arguments[11] as? NSNumber {
            let optionalUTimecodeList = UInt32(exactly: timecodeList)
            if self.timecodeList != optionalUTimecodeList {
                self.timecodeList = optionalUTimecodeList
            }
        }
        OSCMessage.update(&oosSync, withArgument: message.arguments[12])
    }
    
    internal func updateWithCueListLinks(message: OSCMessage) {
        guard message.arguments.count >= 3 else { return }
        guard let uid = message.arguments[1] as? String, let uuid = UUID(uuidString: uid), self.uuid == uuid else { return }
        var linkedCueLists: Set<Double> = []
        for argument in message.arguments[2...] {
            let lists = EosOSCNumber.doubles(from: argument)
            linkedCueLists = linkedCueLists.union(lists)
        }
        if self.links != linkedCueLists {
            self.links = linkedCueLists
        }
    }

}
