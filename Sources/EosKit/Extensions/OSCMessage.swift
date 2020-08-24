//
//  OSCMessage.swift
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

extension OSCMessage {
    
    internal class var ping: OSCMessage { return Cache.EosPing }
    internal class var reset: OSCMessage { return Cache.EosReset }
    internal class var version: OSCMessage { return Cache.EosVersion }
    internal class var filter: OSCMessage { return Cache.EosFilter }
    internal class var EosListCount: OSCMessage { return Cache.EosListCount }
    
    private struct Cache {
        static let EosPing = OSCMessage(with: "/eos/ping", arguments: [])
        static let EosReset = OSCMessage(with: "/eos/reset", arguments: [])
        static let EosVersion = OSCMessage(with: "/eos/get/version", arguments: [])
        static let EosListCount = OSCMessage(with: "/eos/get/cuelist/count", arguments: [])
        static let EosFilter = OSCMessage(with: "/eos/filter/add",
                                       arguments: ["/eos/out/get/version",
                                                   "/eos/out/get/cuelist/count",
                                                   "/eos/out/get/cuelist/*/list/*/*",
                                                   "/eos/out/get/cuelist/*/links/list/*/*",
                                                   "/eos/out/get/cue/*/noparts/count",
                                                   "/eos/out/get/cue/*/*/noparts/list/*/*",
                                                   "/eos/out/get/cue/*/*/noparts/fx/list/*/*",
                                                   "/eos/out/get/cue/*/*/noparts/links/list/*/*",
                                                   "/eos/out/get/cue/*/*/noparts/actions/list/*/*",
                                                   "/eos/out/get/cue/*/*/count",
                                                   "/eos/out/get/cue/*/*/*/list/*/*",
                                                   "/eos/out/get/cue/*/*/*/fx/list/*/*",
                                                   "/eos/out/get/cue/*/*/*/links/list/*/*",
                                                   "/eos/out/get/cue/*/*/*/actions/list/*/*",
                                                   "/eos/out/event/cue/*/*/fire"])
    }
    
    internal func isHeartbeat(with uuid: UUID) -> Bool {
        guard self.addressPattern == eosPingRequest,
              self.arguments.count == 2,
              let argument1 = self.arguments[0] as? String,
              let argument2 = self.arguments[1] as? String else { return false }
        return argument1 == eosHeartbeatString && uuid.uuidString == argument2
    }
    
    internal var isEosReply: Bool { get { self.addressPattern.hasPrefix(eosReplyPrefix)} }
    
    internal func addressWithoutEosReply() -> String {
        let startIndex = self.addressPattern.index(self.addressPattern.startIndex, offsetBy: eosReplyPrefix.count)
        return String(self.addressPattern[startIndex...])
    }


}
