//
//  EosCuesManager.swift
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

internal final class EosCuesManager: EosOptionManagerProtocol {
    
    private let console: EosConsole
    
    init(console: EosConsole) {
        self.console = console
        synchronise()
    }
    
    func synchronise() {
        console.send(message: OSCMessage.eosListCount)
    }
    
    func take(message: OSCMessage) {
        print(message.addressPattern)
        switch message.cueMessageType {
        case .cueListCount:
            guard let count = message.arguments[0] as? Int32 else { return }
            // Request detailed information for each item from index 0 up to count.
            for index in 0..<count {
                console.send(message: OSCMessage(EosGetListWithIndex: index))
            }
        case .cueList:
            print(message.addressPattern)
//            manager.received(message: message, ofType: .cueList)
            console.send(message: OSCMessage(EosGetCueCountForList: Int32(message.addressParts[4])!))
        case .cueListLink:
            print(message.addressPattern)
//            manager.received(message: message, ofType: .cueListLink)
        case .cueCountForList:
            guard let count = message.arguments[0] as? Int32 else { return }
            for index in 0..<count {
                console.send(message: OSCMessage(EosGetCueWithList: Int32(message.addressParts[4])!, andIndex: index))
            }
        case .cue:
//            manager.received(message: message, ofType: .cue)
            console.send(message: OSCMessage(EosGetPartCountForList: Int32(message.addressParts[4])!, andCue: Float32(message.addressParts[5])!))
        case .cueEffects:
            print(message.addressPattern)
//            manager.received(message: message, ofType: .cueEffects)
        case .cueLinks:
            print(message.addressPattern)
//            manager.received(message: message, ofType: .cueLinks)
        case .cueActions:
            print(message.addressPattern)
//            manager.received(message: message, ofType: .cueActions)
        case .partCountForCue:
            guard let count = message.arguments[0] as? Int32 else { return }
            for index in 0..<count where count > 0 {
                console.send(message: OSCMessage(EosGetPartWithList: EosList(for: message), cue: Int32(message.addressParts[5])!, andIndex: index))
            }
        case .part:
            print("INPUT: Part: \(message.addressPattern)")
        case .partEffects:
            print("INPUT: Part Effects: \(message.addressPattern)")
        case .partLinks:
            print("INPUT: Part Links: \(message.addressPattern)")
        case .partActions:
            print("INPUT: Part Actions: \(message.addressPattern)")
        case .unknown:
//            print(message.addressPattern)
            break
        }
    }
    
    private func EosList(for message: OSCMessage) -> Int32 {
        if message.addressParts.count > 3 {
            return Int32(message.addressParts[4])!
        } else {
            return 0
        }
    }
    
}
