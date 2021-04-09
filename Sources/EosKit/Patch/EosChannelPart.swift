//
//  EosChannelPart.swift
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

struct EosChannelPart: Hashable {
    
    internal static var stepCount: Int = 2
    let channelNumber: UInt32
    let number: UInt32
    let uuid: UUID                  // Should never change
    let label: String
    let fixtureManufacturer: String
    let fixtureModel: String
    let address: UInt32
    let intensityAddress: UInt32
    let currentLevel: Int32
    let gel: String
    let text1: String
    let text2: String
    let text3: String
    let text4: String
    let text5: String
    let text6: String
    let text7: String
    let text8: String
    let text9: String
    let text10: String
    let endAddress: UInt32
    let notes: String
    
    init?(messages: [OSCMessage]) {
        guard messages.count == Self.stepCount,
              let indexMessage = messages.first(where: { $0.addressPattern.hasSuffix("notes") == false }),
              let notesMessage = messages.first(where: { $0.addressPattern.hasSuffix("notes") == true }),
              let channelNumber = indexMessage.number(), channelNumber == notesMessage.number(),
              let partNumber = indexMessage.subNumber(), partNumber == notesMessage.subNumber(),
              let uChannelNumber = UInt32(channelNumber),
              let uPartNumber = UInt32(partNumber),
              let uuid = indexMessage.uuid(),
              let label = indexMessage.arguments[2] as? String,
              let fixtureManufacturer = indexMessage.arguments[3] as? String,
              let fixtureModel = indexMessage.arguments[4] as? String,
              let address = indexMessage.arguments[5] as? NSNumber, let uAddress = UInt32(exactly: address),
              let intensityAddress = indexMessage.arguments[6] as? NSNumber, let uIntensityAddress = UInt32(exactly: intensityAddress),
              let currentLevel = indexMessage.arguments[7] as? Int32,
              let gel = indexMessage.arguments[8] as? String,
              let text1 = indexMessage.arguments[9] as? String,
              let text2 = indexMessage.arguments[10] as? String,
              let text3 = indexMessage.arguments[11] as? String,
              let text4 = indexMessage.arguments[12] as? String,
              let text5 = indexMessage.arguments[13] as? String,
              let text6 = indexMessage.arguments[14] as? String,
              let text7 = indexMessage.arguments[15] as? String,
              let text8 = indexMessage.arguments[16] as? String,
              let text9 = indexMessage.arguments[17] as? String,
              let text10 = indexMessage.arguments[18] as? String,
              let endAddress = indexMessage.arguments[20] as? NSNumber, let uEndAddress = UInt32(exactly: endAddress),
              let notes = notesMessage.arguments[2] as? String
        else { return nil }
        self.channelNumber = uChannelNumber
        self.number = uPartNumber
        self.uuid = uuid
        self.label = label
        self.fixtureManufacturer = fixtureManufacturer
        self.fixtureModel = fixtureModel
        self.address = uAddress
        self.intensityAddress = uIntensityAddress
        self.currentLevel = currentLevel
        self.gel = gel
        self.text1 = text1
        self.text2 = text2
        self.text3 = text3
        self.text4 = text4
        self.text5 = text5
        self.text6 = text6
        self.text7 = text7
        self.text8 = text8
        self.text9 = text9
        self.text10 = text10
        self.endAddress = uEndAddress
        self.notes = notes
    }

}

