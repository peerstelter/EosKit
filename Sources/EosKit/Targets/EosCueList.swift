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

public struct EosCueList: EosTarget, Hashable {

    static internal let stepCount: Int = 2
    static internal let target: EosRecordTarget = .cueList
    let number: Double // This is only a Double to conform to EosTarget, in reality it's a UInt32.
    let uuid: UUID
    let label: String
    let playbackMode: String
    let faderMode: String
    let independent: Bool
    let htp: Bool
    let assert: Bool
    let block: Bool
    let background: Bool
    let soloMode: Bool
    let timecodeList: UInt32?
    let oosSync: Bool
    let links: [Double]
    let cues: [EosCue]?
    
    init?(messages: [OSCMessage]) {
        self.init(messages: messages, cues: nil)
    }
    
    init?(messages: [OSCMessage], cues: [EosCue]? = nil) {
        guard messages.count == Self.stepCount,
              let indexMessage = messages.first(where: { $0.addressPattern.contains("links") == false }),
              let linksMessage = messages.first(where: { $0.addressPattern.contains("links") == true }),
              let number = indexMessage.number(), let double = Double(number),
              let uuid = indexMessage.uuid(),
              let label = indexMessage.arguments[2] as? String,
              let playbackMode = indexMessage.arguments[3] as? String,
              let faderMode = indexMessage.arguments[4] as? String,
              let independent = indexMessage.arguments[5] as? OSCArgument,
              let htp = indexMessage.arguments[6] as? OSCArgument,
              let assert = indexMessage.arguments[7] as? OSCArgument,
              let block = indexMessage.arguments[8] as? OSCArgument,
              let background = indexMessage.arguments[9] as? OSCArgument,
              let soloMode = indexMessage.arguments[10] as? OSCArgument,
              let timecodeList = indexMessage.arguments[11] as? NSNumber,
              let oosSync = indexMessage.arguments[12] as? OSCArgument
        else { return nil }
        self.number = double
        self.uuid = uuid
        self.label = label
        self.playbackMode = playbackMode
        self.faderMode = faderMode
        self.independent = independent == .oscTrue
        self.htp = htp == .oscTrue
        self.assert = assert == .oscTrue
        self.block = block == .oscTrue
        self.background = background == .oscTrue
        self.soloMode = soloMode == .oscTrue
        self.timecodeList = UInt32(exactly: timecodeList)
        self.oosSync = oosSync == .oscTrue
        
        var linkedCueLists: [Double] = []
        for argument in linksMessage.arguments[2...] {
            let lists = EosOSCNumber.doubles(from: argument)
            linkedCueLists += lists
        }
        self.links = linkedCueLists.sorted()
        self.cues = cues
    }

}
