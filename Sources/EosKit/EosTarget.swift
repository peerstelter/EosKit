//
//  EosTarget.swift
//  EosKit
//
//  Created by Sam Smallman on 02/04/2021.
//

import Foundation
import OSCKit

internal protocol EosTarget: Hashable {
    
    static var stepCount: Int { get }
    static var target: EosConsoleTarget { get }
    
    var uuid: UUID { get }  // Should never change.
    
    init?(messages: [OSCMessage])
    
}

