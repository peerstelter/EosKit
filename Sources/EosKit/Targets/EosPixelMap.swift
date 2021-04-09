//
//  EosPixelMap.swift
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

struct EosPixelMap: EosTarget, Hashable {

    static internal let stepCount: Int = 2
    static internal let target: EosRecordTarget = .pixelMap
    let number: Double
    let uuid: UUID
    let label: String
    let serverChannel: UInt32
    let interface: String
    let width: UInt32
    let height: UInt32
    let pixelCount: UInt32
    let fixtureCount: UInt32
    let layerChannels: Set<Double>
    
    init?(messages: [OSCMessage]) {
        guard messages.count == Self.stepCount,
              let indexMessage = messages.first(where: { $0.addressPattern.contains("channels") == false }),
              let channelsMessage = messages.first(where: { $0.addressPattern.contains("channels") == true }),
              let number = indexMessage.number(),
              let double = Double(number),
              let uuid = indexMessage.uuid(),
              let label = indexMessage.arguments[2] as? String,
              let serverChannel = indexMessage.arguments[3] as? NSNumber, let uServerChannel = UInt32(exactly: serverChannel),
              let interface = indexMessage.arguments[4] as? String,
              let width = indexMessage.arguments[5] as? NSNumber, let uWidth = UInt32(exactly: width),
              let height = indexMessage.arguments[6] as? NSNumber, let uHeight = UInt32(exactly: height),
              let pixelCount = indexMessage.arguments[7] as? NSNumber, let uPixelCount = UInt32(exactly: pixelCount),
              let fixtureCount = indexMessage.arguments[8] as? NSNumber, let uFixtureCount = UInt32(exactly: fixtureCount)
        else { return nil }
        self.number = double
        self.uuid = uuid
        self.label = label
        self.serverChannel = uServerChannel
        self.interface = interface
        self.width = uWidth
        self.height = uHeight
        self.pixelCount = uPixelCount
        self.fixtureCount = uFixtureCount
        
        var layerChannelsList: Set<Double> = []
        for argument in channelsMessage.arguments[2...] where channelsMessage.arguments.count >= 3 {
            let layerChannelsAsDoubles = EosOSCNumber.doubles(from: argument)
            layerChannelsList = layerChannelsList.union(layerChannelsAsDoubles)
        }
        self.layerChannels = layerChannelsList
    }
    
}
