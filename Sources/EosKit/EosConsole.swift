//
//  EosConsole.swift
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

public final class EosConsole {
    
    public enum ConsoleType: String {
        case nomad = "ETCnomad"
        case nomadPuck = "ETCnomad Puck"
        case element = "Element"
        case element2 = "Element2"
        case ion = "Ion"
        case ionXE = "IonXE"
        case ionXE20 = "IonXE20"
        case eos = "Eos"
        case eosRVI = "Eos RVI"
        case eosRPU = "Eos RPU"
        case ti = "Ti"
        case gio = "Gio"
        case gio5 = "Gio@5"
        case unknown
    }
    
    public let name: String
    public let type: ConsoleType
    public let host: String
    public let port: UInt16
    
    public init(name: String, type: ConsoleType, host: String, port: UInt16) {
        self.name = name
        self.type = type
        self.host = host
        self.port = port
        print("Initialised with \(name) : \(type.rawValue) : \(host) : \(port)")
    }
}
