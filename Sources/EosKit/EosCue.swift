//
//  EosCue.swift
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

class EosCue: EosCueBase {
    
    var listNumber: UInt32
    var number: Double
    var partCount: UInt32
    var parts: Set<EosCuePart> = [] { didSet { parts.forEach { print($0.description) } } }

    var description: String { get { return "Cue \(listNumber)/\(number)\(!label.isEmpty ? " (\(label)):" : ":")" } }
    
    internal init(index: UInt32, listNumber: UInt32, number: Double, uuid: UUID, label: String, upTimeDuration: Int32, upTimeDelay: Int32, downTimeDuration: Int32, downTimeDelay: Int32, focusTimeDuration: Int32, focusTimeDelay: Int32, colorTimeDuration: Int32, colorTimeDelay: Int32, beamTimeDuration: Int32, beamTimeDelay: Int32, preheat: Bool, curve: Double, rate: UInt32, mark: String, block: String, assert: String, link: String, followTime: Int32, hangTime: Int32, allFade: Bool, loop: Int32, solo: Bool, timecode: String, partCount: UInt32, cueNotes: String, sceneText: String, sceneEnd: Bool) {
        self.listNumber = listNumber
        self.number = number
        self.partCount = partCount
        super.init(index: index, uuid: uuid, label: label, upTimeDuration: upTimeDuration, upTimeDelay: upTimeDelay, downTimeDuration: downTimeDuration, downTimeDelay: downTimeDelay, focusTimeDuration: focusTimeDuration, focusTimeDelay: focusTimeDelay, colorTimeDuration: colorTimeDuration, colorTimeDelay: colorTimeDelay, beamTimeDuration: beamTimeDuration, beamTimeDelay: beamTimeDelay, preheat: preheat, curve: curve, rate: rate, mark: mark, block: block, assert: assert, link: link, followTime: followTime, hangTime: hangTime, allFade: allFade, loop: loop, solo: solo, timecode: timecode, cueNotes: cueNotes, sceneText: sceneText, sceneEnd: sceneEnd)
    }
    
    internal static func number(from message: OSCMessage) -> String? {
        guard message.addressParts.count > 4 else { return nil }
        return message.addressParts[3]
    }
    
    internal func updateNumbers(with message: OSCMessage) {
        if let listNumber = EosCueList.number(from: message), let uListNumber = UInt32(listNumber), self.listNumber != uListNumber {
            self.listNumber = uListNumber
        }
        if let number = EosCue.number(from: message), let dNumber = Double(number), self.number != dNumber {
            self.number = dNumber
        }
    }
    
}
