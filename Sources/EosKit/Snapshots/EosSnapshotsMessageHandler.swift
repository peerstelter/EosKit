//
//  EosSnapshotsMessageHandler.swift
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

class EosSnapshotsMessageHandler {
    
    private let console: EosConsole
    private let database: EosSnapshotsDatabase
    private var managerProgress: Progress?
    private var snapshotsProgress: Progress?
    
    init(console: EosConsole, database: EosSnapshotsDatabase, progress: Progress? = nil) {
        self.console = console
        self.database = database
        self.managerProgress = progress
    }
    
    internal func snapshotCount(message: OSCMessage) -> () {
        guard let count = message.arguments[0] as? Int32 else { return }
        snapshotsProgress = Progress(totalUnitCount: Int64(count))
        managerProgress?.addChild(snapshotsProgress!, withPendingUnitCount: 1)
        for index in 0..<count {
            console.send(OSCMessage.eosGetSnapshot(with: "\(index)"))
        }
    }
    
    internal func snapshot(message: OSCMessage) {
        guard let snapshot = EosSnapshot(message: message) else { return }
        database.snapshots.insert(snapshot)
    }
    
}

extension OSCMessage {
    
    // Getting the snapshot count is triggered by the Snapshots Manager so needs to be internal.
    static internal func eosGetSnapshotCount() -> OSCMessage {
        return OSCMessage(with: "/eos/get/snap/count", arguments: [])
    }
    
    static fileprivate func eosGetSnapshot(with index: String) -> OSCMessage {
        return OSCMessage(with: "/eos/get/snap/index/\(index)", arguments: [])
    }

}
