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
    internal let addressSpace = OSCAddressSpace()
    private let database: EosCueDatabase
    private let handler: EosCuesMessageHandler
    
    init(console: EosConsole, progress: Progress? = nil) {
        self.console = console
        self.database = EosCueDatabase()
        self.handler = EosCuesMessageHandler(console: console, database: self.database, progress: progress)
        registerAddressSpace()
    }
    
    private func registerAddressSpace() {
        let cueListCountMethod = OSCAddressMethod(with: "/get/cuelist/count", andCompletionHandler: handler.cueListCount(message:))
        addressSpace.methods.insert(cueListCountMethod)
        let cueListMethod = OSCAddressMethod(with: "/get/cuelist/*/list/*/*", andCompletionHandler: handler.cueList(message:))
        addressSpace.methods.insert(cueListMethod)
        let cueListLinkMethod = OSCAddressMethod(with: "/get/cuelist/*/links/list/*/*", andCompletionHandler: handler.cueListLinks(message:))
        addressSpace.methods.insert(cueListLinkMethod)
        let cueCountForListMethod = OSCAddressMethod(with: "/get/cue/*/count", andCompletionHandler: handler.cueCountForList(message:))
        addressSpace.methods.insert(cueCountForListMethod)
        let cueMethod = OSCAddressMethod(with: "/get/cue/*/*/*/list/*/*", andCompletionHandler: handler.cue(message:))
        addressSpace.methods.insert(cueMethod)
        let cueEffectsMethod = OSCAddressMethod(with: "/get/cue/*/*/*/fx/list/*/*", andCompletionHandler: handler.cueEffects(message:))
        addressSpace.methods.insert(cueEffectsMethod)
        let cueLinksMethod = OSCAddressMethod(with: "/get/cue/*/*/*/links/list/*/*", andCompletionHandler: handler.cueLinks(message:))
        addressSpace.methods.insert(cueLinksMethod)
        let cueActionsMethod = OSCAddressMethod(with: "/get/cue/*/*/*/actions/list/*/*", andCompletionHandler: handler.cueActions(message:))
        addressSpace.methods.insert(cueActionsMethod)
//        let cueCountForListMethod = OSCAddressMethod(with: "/get/cue/*/noparts/count", andCompletionHandler: handler.cueCountForList(message:))
//        addressSpace.methods.insert(cueCountForListMethod)
//        let cueMethod = OSCAddressMethod(with: "/get/cue/*/*/noparts/list/*/*", andCompletionHandler: handler.cue(message:))
//        addressSpace.methods.insert(cueMethod)
//        let cueEffectsMethod = OSCAddressMethod(with: "/get/cue/*/*/noparts/fx/list/*/*", andCompletionHandler: handler.cueEffects(message:))
//        addressSpace.methods.insert(cueEffectsMethod)
//        let cueLinksMethod = OSCAddressMethod(with: "/get/cue/*/*/noparts/links/list/*/*", andCompletionHandler: handler.cueLinks(message:))
//        addressSpace.methods.insert(cueLinksMethod)
//        let cueActionsMethod = OSCAddressMethod(with: "/get/cue/*/*/noparts/actions/list/*/*", andCompletionHandler: handler.cueActions(message:))
//        addressSpace.methods.insert(cueActionsMethod)
    }
    
    func synchronise() {
        console.send(OSCMessage.eosGetCueListCount())
    }
    
}
