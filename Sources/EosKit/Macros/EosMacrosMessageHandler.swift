//
//  EosMacrosMessageHandler.swift
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

class EosMacrosMessageHandler {
    
    private let console: EosConsole
    private let database: EosMacrosDatabase
    private var managerProgress: Progress?
    private var macrosProgress: Progress?
    internal var sectionOneSections: [UUID:EosMacroSectionOne] = [:]
    
    init(console: EosConsole, database: EosMacrosDatabase, progress: Progress? = nil) {
        self.console = console
        self.database = database
        self.managerProgress = progress
    }
    
    internal func macroCount(message: OSCMessage) -> () {
        guard let count = message.arguments[0] as? Int32 else { return }
        macrosProgress = Progress(totalUnitCount: Int64(count))
        managerProgress?.addChild(macrosProgress!, withPendingUnitCount: 1)
        for index in 0..<count {
            console.send(OSCMessage.eosGetMacro(with: "\(index)"))
        }
    }
    
    internal func macro(message: OSCMessage) {
        guard let section = EosMacroSectionOne(message: message) else { return }
        sectionOneSections[section.uuid] = section
    }
    
    internal func macroCommandText(message: OSCMessage) {
        guard let sectionTwo = EosMacroSectionTwo(message: message),
              let sectionOne = sectionOneSections[sectionTwo.uuid]
        else { return }
        let macro = EosMacro(sectionOne: sectionOne, sectionTwo: sectionTwo)
        database.macros.insert(macro)
        sectionOneSections[sectionTwo.uuid] = nil
        guard let macrosProgress = macrosProgress else { return }
        var currentProgress = macrosProgress.completedUnitCount
        currentProgress += 1
        macrosProgress.completedUnitCount = currentProgress
        print("Macros Progress: \(macrosProgress.completedUnitCount) / \(macrosProgress.totalUnitCount)")
    }
    
}

extension OSCMessage {
    
    // Getting the group count is triggered by the Macros Manager so needs to be internal.
    static internal func eosGetMacroCount() -> OSCMessage {
        return OSCMessage(with: "/eos/get/macro/count", arguments: [])
    }
    
    static fileprivate func eosGetMacro(with index: String) -> OSCMessage {
        return OSCMessage(with: "/eos/get/macro/index/\(index)", arguments: [])
    }

}
