//
//  EosSub.swift
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

struct EosSub: EosTarget, Hashable {

    static var stepCount: Int = 2
    static let target: EosRecordTarget = .sub
    let number: Double
    let uuid: UUID
    let label: String
    let mode: String
    let faderMode: String
    let htp: Bool
    let exclusive: Bool
    let background: Bool
    let restore: Bool
//    let priority: String
//    let upTime: Int32       // milliseconds
//    let dwellTime: Int32    // milliseconds
//    let downTime: Int32     // milliseconds
    let effects: Set<Double>
    
    init?(messages: [OSCMessage]) {
        guard messages.count == Self.stepCount,
              let indexMessage = messages.first(where: { $0.addressPattern.contains("fx") == false }),
              let fxMessage = messages.first(where: { $0.addressPattern.contains("fx") == true }),
              let number = indexMessage.number(), number == fxMessage.number(),
              let double = Double(number),
              let uuid = indexMessage.uuid(),
              let label = indexMessage.arguments[2] as? String,
              let mode = indexMessage.arguments[3] as? String,
              let faderMode = indexMessage.arguments[4] as? String,
              let htp = indexMessage.arguments[5] as? OSCArgument,
              let exclusive = indexMessage.arguments[6] as? OSCArgument,
              let background = indexMessage.arguments[7] as? OSCArgument,
              let restore = indexMessage.arguments[8] as? OSCArgument
//              let priority = indexMessage.arguments[9] as? String,
//              let upTime = indexMessage.arguments[10] as? Int32,
//              let dwellTime = indexMessage.arguments[11] as? Int32,
//              let downTime = indexMessage.arguments[12] as? Int32
        else { return nil }
        self.number = double
        self.uuid = uuid
        self.label = label
        self.mode = mode
        self.faderMode = faderMode
        self.htp = htp == .oscTrue
        self.exclusive = exclusive == .oscTrue
        self.background = background  == .oscTrue
        self.restore = restore == .oscTrue
//        self.priority = priority
//        self.upTime = upTime
//        self.dwellTime = dwellTime
//        self.downTime = downTime
        var effectsList: Set<Double> = []
        for argument in fxMessage.arguments[2...] where fxMessage.arguments.count >= 3 {
            let effectsAsDoubles = EosOSCNumber.doubles(from: argument)
            effectsList = effectsList.union(effectsAsDoubles)
        }
        self.effects = effectsList
    }
    
}
