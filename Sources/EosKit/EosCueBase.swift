//
//  EosCueBase.swift
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

class EosCueBase: Hashable {
    
    static func == (lhs: EosCueBase, rhs: EosCueBase) -> Bool {
        return lhs.uuid == rhs.uuid
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(uuid)
    }
    
    var index: UInt32
    let uuid: UUID                  // Should never change
    var label: String
    var upTimeDuration: Int32       // milliseconds
    var upTimeDelay: Int32          // milliseconds
    var downTimeDuration: Int32     // milliseconds
    var downTimeDelay: Int32        // milliseconds
    var focusTimeDuration: Int32    // milliseconds
    var focusTimeDelay: Int32       // milliseconds
    var colorTimeDuration: Int32    // milliseconds
    var colorTimeDelay: Int32       // milliseconds
    var beamTimeDuration: Int32     // milliseconds
    var beamTimeDelay: Int32        // milliseconds
    var preheat: Bool               // TODO: Preheat levels?
    var curve: Double?              // OSC Number
    var rate: UInt32
    var mark: String                // "m", "M" or ""
    var block: String               // "b", "B" or ""
    var assert: String              // "a", "A" or ""
    var link: String                // OSC Number or String - String if links to a separate cue list.
    var followTime: Int32           // milliseconds
    var hangTime: Int32             // milliseconds
    var allFade: Bool
    var loop: Int32
    var solo: Bool
    var timecode: String
    var cueNotes: String { didSet { print(cueNotes) } }
    var sceneText: String
    var sceneEnd: Bool
    var effects: Set<Double> = []
    var links: Set<Double> = []
    var actions: String = ""
    
    internal init(index: UInt32, uuid: UUID, label: String, upTimeDuration: Int32, upTimeDelay: Int32, downTimeDuration: Int32, downTimeDelay: Int32, focusTimeDuration: Int32, focusTimeDelay: Int32, colorTimeDuration: Int32, colorTimeDelay: Int32, beamTimeDuration: Int32, beamTimeDelay: Int32, preheat: Bool, curve: Double, rate: UInt32, mark: String, block: String, assert: String, link: String, followTime: Int32, hangTime: Int32, allFade: Bool, loop: Int32, solo: Bool, timecode: String, cueNotes: String, sceneText: String, sceneEnd: Bool) {
        self.index = index
        self.uuid = uuid
        self.label = label
        self.upTimeDuration = upTimeDuration
        self.upTimeDelay = upTimeDelay
        self.downTimeDuration = downTimeDuration
        self.downTimeDelay = downTimeDelay
        self.focusTimeDuration = focusTimeDuration
        self.focusTimeDelay = focusTimeDelay
        self.colorTimeDuration = colorTimeDuration
        self.colorTimeDelay = colorTimeDelay
        self.beamTimeDuration = beamTimeDuration
        self.beamTimeDelay = beamTimeDelay
        self.preheat = preheat
        self.curve = curve
        self.rate = rate
        self.mark = mark
        self.block = block
        self.assert = assert
        self.link = link
        self.followTime = followTime
        self.hangTime = hangTime
        self.allFade = allFade
        self.loop = loop
        self.solo = solo
        self.timecode = timecode
        self.cueNotes = cueNotes
        self.sceneText = sceneText
        self.sceneEnd = sceneEnd
    }
    
    internal static func cue(from message: OSCMessage) -> EosCue? {
        guard message.arguments.count >= 30 else { return nil }
        guard let index = message.arguments[0] as? NSNumber, let uIndex = UInt32(exactly: index) else { return nil }
        guard let listNumber = EosCueList.number(from: message), let uListNumber = UInt32(listNumber) else { return nil }
        guard let number = EosCue.number(from: message), let dNumber = Double(number) else { return nil }
        guard let uid = message.arguments[1] as? String, let uuid = UUID(uuidString: uid) else { return nil }
        guard let label = message.arguments[2] as? String else { return nil }
        guard let upTimeDuration = message.arguments[3] as? Int32 else { return nil }
        guard let upTimeDelay = message.arguments[4] as? Int32 else { return nil }
        guard let downTimeDuration = message.arguments[5] as? Int32 else { return nil }
        guard let downTimeDelay = message.arguments[6] as? Int32 else { return nil }
        guard let focusTimeDuration = message.arguments[7] as? Int32 else { return nil }
        guard let focusTimeDelay = message.arguments[8] as? Int32 else { return nil }
        guard let colorTimeDuration = message.arguments[9] as? Int32 else { return nil }
        guard let colorTimeDelay = message.arguments[10] as? Int32 else { return nil }
        guard let beamTimeDuration = message.arguments[11] as? Int32 else { return nil }
        guard let beamTimeDelay = message.arguments[12] as? Int32 else { return nil }
        guard let preheat = message.arguments[13] as? OSCArgument else { return nil }
        guard let curve = EosOSCNumber.doubles(from:  message.arguments[14]).first else { return nil }
        guard let rate = message.arguments[15] as? NSNumber, let uRate = UInt32(exactly: rate) else { return nil }
        guard let mark = message.arguments[16] as? String else { return nil }
        guard let block = message.arguments[17] as? String else { return nil }
        guard let assert = message.arguments[18] as? String else { return nil }
        guard let link = self.link(from: message.arguments[19]) else { return nil }
        guard let followTime = message.arguments[20] as? Int32 else { return nil }
        guard let hangTime = message.arguments[21] as? Int32 else { return nil }
        guard let allFade = message.arguments[22] as? OSCArgument else { return nil }
        guard let loop = message.arguments[23] as? Int32 else { return nil }
        guard let solo = message.arguments[24] as? OSCArgument else { return nil }
        guard let timecode = message.arguments[25] as? String else { return nil }
        guard let partCount = message.arguments[26] as? NSNumber, let uPartCount = UInt32(exactly: partCount) else { return nil }
        guard let cueNotes = message.arguments[27] as? String else { return nil }
        guard let sceneText = message.arguments[28] as? String else { return nil }
        guard let sceneEnd = message.arguments[29] as? OSCArgument else { return nil }
        return EosCue(index: uIndex, listNumber: uListNumber, number: dNumber, uuid: uuid, label: label, upTimeDuration: upTimeDuration, upTimeDelay: upTimeDelay, downTimeDuration: downTimeDuration, downTimeDelay: downTimeDelay, focusTimeDuration: focusTimeDuration, focusTimeDelay: focusTimeDelay, colorTimeDuration: colorTimeDuration, colorTimeDelay: colorTimeDelay, beamTimeDuration: beamTimeDuration, beamTimeDelay: beamTimeDelay, preheat: preheat == .oscTrue, curve: curve, rate: uRate, mark: mark, block: block, assert: assert, link: link, followTime: followTime, hangTime: hangTime, allFade: allFade == .oscTrue, loop: loop, solo: solo == .oscTrue, timecode: timecode, partCount: uPartCount, cueNotes: cueNotes, sceneText: sceneText, sceneEnd: sceneEnd == .oscTrue)
    }
    
    internal static func part(from message: OSCMessage) -> EosCuePart? {
        guard message.arguments.count >= 30 else { return nil }
        guard let index = message.arguments[0] as? NSNumber, let uIndex = UInt32(exactly: index) else { return nil }
        guard let listNumber = EosCueList.number(from: message), let uListNumber = UInt32(listNumber) else { return nil }
        guard let cueNumber = EosCue.number(from: message), let dCueNumber = Double(cueNumber) else { return nil }
        guard let number = EosCuePart.number(from: message), let uNumber = UInt32(number) else { return nil }
        guard let uid = message.arguments[1] as? String, let uuid = UUID(uuidString: uid) else { return nil }
        guard let label = message.arguments[2] as? String else { return nil }
        guard let upTimeDuration = message.arguments[3] as? Int32 else { return nil }
        guard let upTimeDelay = message.arguments[4] as? Int32 else { return nil }
        guard let downTimeDuration = message.arguments[5] as? Int32 else { return nil }
        guard let downTimeDelay = message.arguments[6] as? Int32 else { return nil }
        guard let focusTimeDuration = message.arguments[7] as? Int32 else { return nil }
        guard let focusTimeDelay = message.arguments[8] as? Int32 else { return nil }
        guard let colorTimeDuration = message.arguments[9] as? Int32 else { return nil }
        guard let colorTimeDelay = message.arguments[10] as? Int32 else { return nil }
        guard let beamTimeDuration = message.arguments[11] as? Int32 else { return nil }
        guard let beamTimeDelay = message.arguments[12] as? Int32 else { return nil }
        guard let preheat = message.arguments[13] as? OSCArgument else { return nil }
        guard let curve = EosOSCNumber.doubles(from:  message.arguments[14]).first else { return nil }
        guard let rate = message.arguments[15] as? NSNumber, let uRate = UInt32(exactly: rate) else { return nil }
        guard let mark = message.arguments[16] as? String else { return nil }
        guard let block = message.arguments[17] as? String else { return nil }
        guard let assert = message.arguments[18] as? String else { return nil }
        guard let link = self.link(from: message.arguments[19]) else { return nil }
        guard let followTime = message.arguments[20] as? Int32 else { return nil }
        guard let hangTime = message.arguments[21] as? Int32 else { return nil }
        guard let allFade = message.arguments[22] as? OSCArgument else { return nil }
        guard let loop = message.arguments[23] as? Int32 else { return nil }
        guard let solo = message.arguments[24] as? OSCArgument else { return nil }
        guard let timecode = message.arguments[25] as? String else { return nil }
        guard let cueNotes = message.arguments[27] as? String else { return nil }
        guard let sceneText = message.arguments[28] as? String else { return nil }
        guard let sceneEnd = message.arguments[29] as? OSCArgument else { return nil }
        return EosCuePart(index: uIndex, listNumber: uListNumber, cueNumber: dCueNumber, number: uNumber, uuid: uuid, label: label, upTimeDuration: upTimeDuration, upTimeDelay: upTimeDelay, downTimeDuration: downTimeDuration, downTimeDelay: downTimeDelay, focusTimeDuration: focusTimeDuration, focusTimeDelay: focusTimeDelay, colorTimeDuration: colorTimeDuration, colorTimeDelay: colorTimeDelay, beamTimeDuration: beamTimeDuration, beamTimeDelay: beamTimeDelay, preheat: preheat == .oscTrue, curve: curve, rate: uRate, mark: mark, block: block, assert: assert, link: link, followTime: followTime, hangTime: hangTime, allFade: allFade == .oscTrue, loop: loop, solo: solo == .oscTrue, timecode: timecode, cueNotes: cueNotes, sceneText: sceneText, sceneEnd: sceneEnd == .oscTrue)
    }

    
    private static func link(from any: Any) -> String? {
        if let int = any as? Int32 {
            return int == 0 ? "" : String(int)
        }
        if let string = any as? String {
            return string
        }
        return nil
    }
    
    internal func updateWith(message: OSCMessage) {
        guard message.arguments.count >= 30 else { return }
        guard let uid = message.arguments[1] as? String, let uuid = UUID(uuidString: uid), self.uuid == uuid else { return }
        OSCMessage.update(&index, withArgument: message.arguments[0])
        OSCMessage.update(&label, withArgument: message.arguments[2])
        OSCMessage.update(&upTimeDuration, withArgument: message.arguments[3])
        OSCMessage.update(&upTimeDelay, withArgument: message.arguments[4])
        OSCMessage.update(&downTimeDuration, withArgument: message.arguments[5])
        OSCMessage.update(&downTimeDelay, withArgument: message.arguments[6])
        OSCMessage.update(&focusTimeDuration, withArgument: message.arguments[7])
        OSCMessage.update(&focusTimeDelay, withArgument: message.arguments[8])
        OSCMessage.update(&colorTimeDuration, withArgument: message.arguments[9])
        OSCMessage.update(&colorTimeDelay, withArgument: message.arguments[10])
        OSCMessage.update(&beamTimeDuration, withArgument: message.arguments[11])
        OSCMessage.update(&beamTimeDelay, withArgument: message.arguments[12])
        OSCMessage.update(&preheat, withArgument: message.arguments[13])
        if let curve = EosOSCNumber.doubles(from:  message.arguments[13]).first, self.curve != curve {
            self.curve = curve
        }
        OSCMessage.update(&rate, withArgument: message.arguments[15])
        OSCMessage.update(&mark, withArgument: message.arguments[16])
        OSCMessage.update(&block, withArgument: message.arguments[17])
        OSCMessage.update(&assert, withArgument: message.arguments[18])
        OSCMessage.update(&link, withArgument: message.arguments[19])
        OSCMessage.update(&followTime, withArgument: message.arguments[20])
        OSCMessage.update(&hangTime, withArgument: message.arguments[21])
        OSCMessage.update(&allFade, withArgument: message.arguments[22])
        OSCMessage.update(&loop, withArgument: message.arguments[23])
        OSCMessage.update(&solo, withArgument: message.arguments[24])
        OSCMessage.update(&timecode, withArgument: message.arguments[25])
        OSCMessage.update(&cueNotes, withArgument: message.arguments[27])
        OSCMessage.update(&sceneText, withArgument: message.arguments[28])
        OSCMessage.update(&sceneEnd, withArgument: message.arguments[29])
    }
    
    internal func updateWithEffects(message: OSCMessage) {
        guard message.arguments.count >= 3 else { return }
        guard let uid = message.arguments[1] as? String, let uuid = UUID(uuidString: uid), self.uuid == uuid else { return }
        var effectsList: Set<Double> = []
        for argument in message.arguments[2...] {
            let effects = EosOSCNumber.doubles(from: argument)
            effectsList = effectsList.union(effects)
        }
        if self.effects != effectsList {
            self.effects = effectsList
        }
    }
    
    internal func updateWithLinks(message: OSCMessage) {
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
    
    internal func updateWithActions(message: OSCMessage) {
        guard message.arguments.count >= 3 else { return }
        guard let uid = message.arguments[1] as? String, let uuid = UUID(uuidString: uid), self.uuid == uuid else { return }
        OSCMessage.update(&actions, withArgument: message.arguments[2])
    }

}
