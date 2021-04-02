//
//  EosMacro.swift
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

struct EosMacro: EosTarget, Hashable {
    
    let number: UInt32
    let uuid: UUID
    let label: String
    let mode: String
    let commandText: String
    
    internal init(sectionOne: EosMacroSectionOne, sectionTwo: EosMacroSectionTwo) {
        self.number = sectionOne.number
        self.uuid = sectionOne.uuid
        self.label = sectionOne.label
        self.mode = sectionOne.mode
        self.commandText = sectionTwo.commandText
    }
    
}

internal struct EosMacroSectionOne {
    let number: UInt32
    let uuid: UUID
    let label: String
    let mode: String
    
    init?(message: OSCMessage) {
        guard let number = EosMacro.number(from: message),
              let uNumber = UInt32(number),
              let uuid = EosMacro.uuid(from: message),
              let label = message.arguments[2] as? String,
              let mode = message.arguments[3] as? String
        else { return nil }
        self.number = uNumber
        self.uuid = uuid
        self.label = label
        self.mode = mode
    }
}

internal struct EosMacroSectionTwo {
    let number: UInt32
    let uuid: UUID
    let commandText: String
    
    init?(message: OSCMessage) {
        guard let number = EosMacro.number(from: message),
              let uNumber = UInt32(number),
              let uuid = EosMacro.uuid(from: message),
              let commandText = message.arguments[2] as? String
        else { return nil }
        self.number = uNumber
        self.uuid = uuid
        self.commandText = commandText
    }
}
