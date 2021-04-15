//
//  EosCueDatabase.swift
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
//
//internal class EosCueDatabase {
//    
//    private (set) public var lists: Set<EosCueList> = []
//    
//    internal func add(list: EosCueList) {
//        lists.insert(list)
//    }
//    
//    internal func remove(list: EosCueList) {
//        lists.remove(list)
//    }
//    
//    internal func list(with uuid: UUID) -> EosCueList? {
//        return lists.first(where: { $0.uuid == uuid })
//    }
//    
//    internal func list(with number: UInt32) -> EosCueList? {
//        return lists.first(where: { $0.number == number })
//    }
//    
//    internal func cue(with uuid: UUID, inListWithNumber listNumber: UInt32) -> EosCue? {
//        guard let list = list(with: listNumber) else { return nil }
//        return list.cues.first(where: { $0.uuid == uuid })
//    }
//    
//    internal func add(cue: EosCue, toListWithNumber listNumber: UInt32) -> Bool {
//        guard let list = list(with: listNumber) else { return false }
//        list.cues.insert(cue)
//        return true
//    }
//    
//    internal func part(with uuid: UUID, inCueWithNumber cueNumber: Double, inListWithNumber listNumber: UInt32) -> EosCuePart? {
//        guard let list = list(with: listNumber) else { return nil }
//        guard let cue = list.cues.first(where: { $0.number == cueNumber }) else { return nil }
//        return cue.parts.first(where: { $0.uuid == uuid })
//    }
//    
//    internal func add(part: EosCuePart, toCueWithNumber cueNumber: Double, inListWithNumber listNumber: UInt32) -> Bool {
//        guard let list = list(with: listNumber) else { return false }
//        guard let cue = list.cues.first(where: { $0.number == cueNumber }) else { return false }
//        cue.parts.insert(part)
//        return true
//    }
//
//}
