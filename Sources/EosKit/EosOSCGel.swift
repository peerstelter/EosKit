//
//  EosOSCGel.swift
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

public enum EosOSCGel: CaseIterable {
    public static var allCases: [EosOSCGel] {
        return [.apollo(gel: 0), .gam(gel: 0), .lee(gel: 0), .rosco(gel: 0), .roscoSuperGel(gel: 0), .roscoEColor(gel: 0), .tokyoBSPolyColor(gel: 0)]
    }
    
    case apollo(gel: UInt32)
    case gam(gel: UInt32)
    case lee(gel: UInt32)
    case rosco(gel: UInt32)
    case roscoSuperGel(gel: UInt32)
    case roscoEColor(gel: UInt32)
    case tokyoBSPolyColor(gel: UInt32)
    
    var prefix: String {
        switch self {
        case .apollo(gel: _): return "AP"
        case .gam(gel: _): return "G"
        case .lee(gel: _): return "L"
        case .rosco(gel: _): return "R"
        case .roscoSuperGel(gel: _): return "SG"
        case .roscoEColor(gel: _): return "E"
        case .tokyoBSPolyColor(gel: _): return "T"
        }
    }
    
    var oscGelString: String {
        switch self {
        case.apollo(gel: let gel): return self.prefix + "\(gel)"
        case .gam(gel: let gel): return self.prefix + "\(gel)"
        case .lee(gel: let gel): return self.prefix + "\(gel)"
        case .rosco(gel: let gel): return self.prefix + "\(gel)"
        case .roscoSuperGel(gel: let gel): return self.prefix + "\(gel)"
        case .roscoEColor(gel: let gel): return self.prefix + "\(gel)"
        case .tokyoBSPolyColor(gel: let gel): return self.prefix + "\(gel)"
        }
    }
    
    internal static func gel(from string: String) -> EosOSCGel? {
        for item in EosOSCGel.allCases {
            if string.hasPrefix(item.prefix) {
                let numberString = String(string.dropFirst(item.prefix.count))
                guard let number = UInt32(numberString) else { return nil }
                switch item {
                case .apollo(gel: _):
                    return EosOSCGel.apollo(gel: number)
                case .gam(gel: _):
                    return EosOSCGel.gam(gel: number)
                case .lee(gel: _):
                    return EosOSCGel.lee(gel: number)
                case .rosco(gel: _):
                    return EosOSCGel.rosco(gel: number)
                case .roscoEColor(gel: _):
                    return EosOSCGel.roscoEColor(gel: number)
                case .roscoSuperGel(gel: _):
                    return EosOSCGel.roscoSuperGel(gel: number)
                case .tokyoBSPolyColor(gel: _):
                    return EosOSCGel.tokyoBSPolyColor(gel: number)
                }
            }
        }
        return nil
    }

}


