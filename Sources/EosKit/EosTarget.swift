//
//  EosTarget.swift
//  EosKit
//
//  Created by Sam Smallman on 02/04/2021.
//

import Foundation
import OSCKit

internal protocol EosTarget {
    var uuid: UUID { get }  // Should never change.
    static func uuid(from message: OSCMessage) -> UUID?
    static func number(from message: OSCMessage) -> String?
}

extension EosTarget {
    
    static func uuid(from message: OSCMessage) -> UUID? {
        guard let id = message.arguments[1] as? String, let uuid = UUID(uuidString: id) else { return nil }
        return uuid
    }
    
    internal static func number(from message: OSCMessage) -> String? {
        guard message.addressParts.count > 3 else { return nil }
        return message.addressParts[2]
    }
    
}
