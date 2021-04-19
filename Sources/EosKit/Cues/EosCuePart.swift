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

public struct EosCuePart: Hashable {

    static internal let stepCount: Int = 4
    let listNumber: Double          // This is only a Double to conform to EosTarget, in reality it's a UInt32.
    let cueNumber: Double
    let number: UInt32
    let uuid: UUID
    let label: String
    let upTimeDuration: Int32       // milliseconds
    let upTimeDelay: Int32          // milliseconds
    let downTimeDuration: Int32     // milliseconds
    let downTimeDelay: Int32        // milliseconds
    let focusTimeDuration: Int32    // milliseconds
    let focusTimeDelay: Int32       // milliseconds
    let colorTimeDuration: Int32    // milliseconds
    let colorTimeDelay: Int32       // milliseconds
    let beamTimeDuration: Int32     // milliseconds
    let beamTimeDelay: Int32        // milliseconds
    let preheat: Bool               // TODO: Preheat levels?
    let curve: Double?              // OSC Number
    let rate: UInt32
    let mark: String                // "m", "M" or ""
    let block: String               // "b", "B" or ""
    let assert: String              // "a", "A" or ""
    let link: String                // OSC Number or String - String if links to a separate cue list.
    let followTime: Int32           // milliseconds
    let hangTime: Int32             // milliseconds
    let allFade: Bool
    let loop: Int32
    let solo: Bool
    let timecode: String
    let cueNotes: String
    let sceneText: String
    let sceneEnd: Bool
    let effects: [Double]
    let links: [Double]
    let actions: String
    
    init?(messages: [OSCMessage]) {
        guard messages.count == Self.stepCount,
              let indexMessage = messages.first(where: { $0.addressPattern.contains("fx") == false &&
                                                         $0.addressPattern.contains("links") == false &&
                                                         $0.addressPattern.contains("actions") == false }),
              let fxMessage = messages.first(where: { $0.addressPattern.contains("fx") == true }),
              let linksMessage = messages.first(where: { $0.addressPattern.contains("links") == true }),
              let actionsMessage = messages.first(where: { $0.addressPattern.contains("actions") == true }),
              let listNumber = indexMessage.number(), let dListNumber = Double(listNumber),
              let cueNumber = indexMessage.subNumber(), let dCueNumber = Double(cueNumber),
              let number = UInt32(indexMessage.addressParts[4]),
              let uuid = indexMessage.uuid(),
              let label = indexMessage.arguments[2] as? String,
              let upTimeDuration = indexMessage.arguments[3] as? Int32,
              let upTimeDelay = indexMessage.arguments[4] as? Int32,
              let downTimeDuration = indexMessage.arguments[5] as? Int32,
              let downTimeDelay = indexMessage.arguments[6] as? Int32,
              let focusTimeDuration = indexMessage.arguments[7] as? Int32,
              let focusTimeDelay = indexMessage.arguments[8] as? Int32,
              let colorTimeDuration = indexMessage.arguments[9] as? Int32,
              let colorTimeDelay = indexMessage.arguments[10] as? Int32,
              let beamTimeDuration = indexMessage.arguments[11] as? Int32,
              let beamTimeDelay = indexMessage.arguments[12] as? Int32,
              let preheat = indexMessage.arguments[13] as? OSCArgument,
              let curve = EosOSCNumber.doubles(from:  indexMessage.arguments[14]).first,
              let rate = indexMessage.arguments[15] as? NSNumber, let uRate = UInt32(exactly: rate),
              let mark = indexMessage.arguments[16] as? String,
              let block = indexMessage.arguments[17] as? String,
              let assert = indexMessage.arguments[18] as? String,
              let link = EosCue.link(from: indexMessage.arguments[19]),
              let followTime = indexMessage.arguments[20] as? Int32,
              let hangTime = indexMessage.arguments[21] as? Int32,
              let allFade = indexMessage.arguments[22] as? OSCArgument,
              let loop = indexMessage.arguments[23] as? Int32,
              let solo = indexMessage.arguments[24] as? OSCArgument,
              let timecode = indexMessage.arguments[25] as? String,
              let cueNotes = indexMessage.arguments[27] as? String,
              let sceneText = indexMessage.arguments[28] as? String,
              let sceneEnd = indexMessage.arguments[29] as? OSCArgument
        else { return nil }
        self.listNumber = dListNumber
        self.cueNumber = dCueNumber
        self.number = number
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
        self.preheat = preheat == .oscTrue
        self.curve = curve
        self.rate = uRate
        self.mark = mark
        self.block = block
        self.assert = assert
        self.link = link
        self.followTime = followTime
        self.hangTime = hangTime
        self.allFade = allFade == .oscTrue
        self.loop = loop
        self.solo = solo == .oscTrue
        self.timecode = timecode
        self.cueNotes = cueNotes
        self.sceneText = sceneText
        self.sceneEnd = sceneEnd == .oscTrue
        
        var effectsList: [Double] = []
        for argument in fxMessage.arguments[2...] {
            let effects = EosOSCNumber.doubles(from: argument)
            effectsList += effects
        }
        self.effects = effectsList
        
        var linkedCueLists: [Double] = []
        for argument in linksMessage.arguments[2...] {
            let lists = EosOSCNumber.doubles(from: argument)
            linkedCueLists += lists
        }
        self.links = linkedCueLists
        
        if actionsMessage.arguments.count == 3, let actions = actionsMessage.arguments[2] as? String {
            self.actions = actions
        } else {
            self.actions = ""
        }
        
    }
    
    internal static func link(from any: Any) -> String? {
        if let int = any as? Int32 {
            return int == 0 ? "" : String(int)
        }
        if let string = any as? String {
            return string
        }
        return nil
    }
    
}

extension EosCuePart: CustomStringConvertible {
    
    public var description: String {
        "Cue \(cueNumber) Part \(number)\(label.isEmpty == true ? "" : " - \(label)")"
    }
    
}
