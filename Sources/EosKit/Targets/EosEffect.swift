//
//  EosEffect.swift
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

public struct EosEffect: EosTarget, Hashable {

    static internal let stepCount: Int = 1
    static internal let target: EosRecordTarget = .effect
    let number: Double
    let uuid: UUID
    let label: String
    let type: String
    let entry: String
    let exit: String
    let duration: String
    let scale: UInt32
    
    init?(messages: [OSCMessage]) {
        guard messages.count == Self.stepCount,
              let indexMessage = messages.first,
              let number = indexMessage.number(),
              let double = Double(number),
              let uuid = indexMessage.uuid(),
              let label = indexMessage.arguments[2] as? String,
              let type = indexMessage.arguments[3] as? String,
              let entry = indexMessage.arguments[4] as? String,
              let exit = indexMessage.arguments[5] as? String,
              let duration = indexMessage.arguments[6] as? String,
              let scale = indexMessage.arguments[7] as? NSNumber, let uScale = UInt32(exactly: scale)
        else { return nil }
        self.number = double
        self.uuid = uuid
        self.label = label
        self.type = type
        self.entry = entry
        self.exit = exit
        self.duration = duration
        self.scale = uScale
    }

}
