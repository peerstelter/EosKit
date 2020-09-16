//
//  EosOSCNumber.swift
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

internal class EosOSCNumber {
    
    /*
     Eos target numbers will be sent as 32-bit integers when possible. If they are not whole numbers (ex: Cue 1.23) then they will be sent as strings.
     E.g.
     10
     “1.23”
     
     When a range numbers contains 2 or more consecutive whole numbers, they will be represented as strings in the following format: X-Y
     E.g.
     “1-100”
     */

    // MARK: - Helper

    static func doubles(from numbersAndRanges: Any) -> [Double] {
        if let number = numbersAndRanges as? Int32 {
            return [Double(number)]
        } else if let number = numbersAndRanges as? String {
            if number.contains("-") {
                let rangeArray = number.components(separatedBy: "-")
                guard let firstNumber = rangeArray.first, let firstInt = Int(firstNumber), let lastNumber = rangeArray.last, let lastInt = Int(lastNumber), rangeArray.count == 2 else { return [] }
                return Array(firstInt...lastInt).map { Double($0) }
            }
            if let oscNumber = Double(number) {
                return [oscNumber]
            }
        }
        return []
    }
    
}

