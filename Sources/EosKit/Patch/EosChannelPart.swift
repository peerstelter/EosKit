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

class EosChannelPart: Hashable {

    static func == (lhs: EosChannelPart, rhs: EosChannelPart) -> Bool {
        return lhs.uuid == rhs.uuid
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(uuid)
    }
    
    var channelNumber: UInt32
    var number: UInt32
    let uuid: UUID                  // Should never change
    var label: String
    var fixtureManufacturer: String
    var fixtureModel: String
    var address: UInt32
    var intensityAddress: UInt32
    var currentLevel: Int32
    var gel: EosOSCGel?
    var text1: String
    var text2: String
    var text3: String
    var text4: String
    var text5: String
    var text6: String
    var text7: String
    var text8: String
    var text9: String
    var text10: String
    var endAddress: UInt32
    var notes: String = ""
    
    internal init(channelNumber: UInt32, number: UInt32, uuid: UUID, label: String, fixtureManufacturer: String, fixtureModel: String, address: UInt32, intensityAddress: UInt32, currentLevel: Int32, gel: EosOSCGel?, text1: String, text2: String, text3: String, text4: String, text5: String, text6: String, text7: String, text8: String, text9: String, text10: String, endAddress: UInt32) {
        self.channelNumber = channelNumber
        self.number = number
        self.uuid = uuid
        self.label = label
        self.fixtureManufacturer = fixtureManufacturer
        self.fixtureModel = fixtureModel
        self.address = address
        self.intensityAddress = intensityAddress
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
        self.endAddress = endAddress
    }
    
    internal static func part(from message: OSCMessage) -> EosChannelPart? {
        guard message.arguments.count >= 21 else { return nil }
        guard let channelNumber = EosChannel.number(from: message), let uChannelNumber = UInt32(channelNumber) else { return nil }
        guard let number = EosChannelPart.number(from: message), let uNumber = UInt32(number) else { return nil }
        guard let uid = message.arguments[1] as? String, let uuid = UUID(uuidString: uid) else { return nil }
        guard let label = message.arguments[2] as? String else { return nil }
        guard let fixtureManufacturer = message.arguments[3] as? String else { return nil }
        guard let fixtureModel = message.arguments[4] as? String else { return nil }
        guard let address = message.arguments[5] as? NSNumber, let uAddress = UInt32(exactly: address) else { return nil }
        guard let intensityAddress = message.arguments[6] as? NSNumber, let uIntensityAddress = UInt32(exactly: intensityAddress) else { return nil }
        guard let currentLevel = message.arguments[7] as? Int32 else { return nil }
        guard let string = message.arguments[8] as? String else { return nil }
        guard let text1 = message.arguments[9] as? String else { return nil }
        guard let text2 = message.arguments[10] as? String else { return nil }
        guard let text3 = message.arguments[11] as? String else { return nil }
        guard let text4 = message.arguments[12] as? String else { return nil }
        guard let text5 = message.arguments[13] as? String else { return nil }
        guard let text6 = message.arguments[14] as? String else { return nil }
        guard let text7 = message.arguments[15] as? String else { return nil }
        guard let text8 = message.arguments[16] as? String else { return nil }
        guard let text9 = message.arguments[17] as? String else { return nil }
        guard let text10 = message.arguments[18] as? String else { return nil }
        guard let endAddress = message.arguments[20] as? NSNumber, let uEndAddress = UInt32(exactly: endAddress) else { return nil }
        return EosChannelPart(channelNumber: uChannelNumber, number: uNumber, uuid: uuid, label: label, fixtureManufacturer: fixtureManufacturer, fixtureModel: fixtureModel, address: uAddress, intensityAddress: uIntensityAddress, currentLevel: currentLevel, gel: EosOSCGel.gel(from: string), text1: text1, text2: text2, text3: text3, text4: text4, text5: text5, text6: text6, text7: text7, text8: text8, text9: text9, text10: text10, endAddress: uEndAddress)
    }
    
    internal func updateWith(message: OSCMessage) {
        guard message.arguments.count >= 21 else { return }
        guard let uid = message.arguments[1] as? String, let uuid = UUID(uuidString: uid), self.uuid == uuid else { return }
        OSCMessage.update(&label, withArgument: message.arguments[2])
        OSCMessage.update(&fixtureManufacturer, withArgument: message.arguments[3])
        OSCMessage.update(&fixtureModel, withArgument: message.arguments[4])
        OSCMessage.update(&address, withArgument: message.arguments[5])
        OSCMessage.update(&intensityAddress, withArgument: message.arguments[6])
        OSCMessage.update(&currentLevel, withArgument: message.arguments[7])
        if let string = message.arguments[8] as? String, string != self.gel?.oscGelString, let gel = EosOSCGel.gel(from: string){
            self.gel = gel
        }
        OSCMessage.update(&text1, withArgument: message.arguments[9])
        OSCMessage.update(&text2, withArgument: message.arguments[10])
        OSCMessage.update(&text3, withArgument: message.arguments[11])
        OSCMessage.update(&text4, withArgument: message.arguments[12])
        OSCMessage.update(&text5, withArgument: message.arguments[13])
        OSCMessage.update(&text6, withArgument: message.arguments[14])
        OSCMessage.update(&text7, withArgument: message.arguments[15])
        OSCMessage.update(&text8, withArgument: message.arguments[16])
        OSCMessage.update(&text9, withArgument: message.arguments[17])
        OSCMessage.update(&text10, withArgument: message.arguments[18])
        OSCMessage.update(&endAddress, withArgument: message.arguments[20])
    }
    
    internal static func number(from message: OSCMessage) -> String? {
        guard message.addressParts.count > 4 else { return nil }
        return message.addressParts[3]
    }
    
    internal func updateNumbers(with message: OSCMessage) {
        if let channelNumber = EosChannel.number(from: message), let uChannelNumber = UInt32(channelNumber), self.channelNumber != uChannelNumber {
            self.channelNumber = uChannelNumber
        }
        if let number = EosChannelPart.number(from: message), let uNumber = UInt32(number), self.number != uNumber {
            self.number = uNumber
        }
    }
    
    internal func updateWithNotes(message: OSCMessage) {
        guard message.arguments.count >= 3 else { return }
        guard let uid = message.arguments[1] as? String, let uuid = UUID(uuidString: uid), self.uuid == uuid else { return }
        OSCMessage.update(&notes, withArgument: message.arguments[2])
    }
}

