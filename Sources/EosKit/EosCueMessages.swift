//
//  EosCueMessages.swift
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

public enum EosCueMessageType {
    case cueListCount
    case cueList
    case cueListLink
    case cueCountForList
    case cue
    case cueEffects
    case cueLinks
    case cueActions
    case partCountForCue
    case part
    case partEffects
    case partLinks
    case partActions
    case unknown
}

extension OSCMessage {
    
    public var cueMessageType: EosCueMessageType {
        get {
            if self.isCueListCount {
                return .cueListCount
            } else if self.isCueList {
                return .cueList
            } else if self.isCueListLink {
                return .cueListLink
            } else if self.isCueCountForList {
                return .cueCountForList
            } else if self.isCue {
                return .cue
            } else if self.isCueEffects {
                return .cueEffects
            } else if self.isCueLinks {
                return .cueLinks
            } else if self.isCueActions {
                return .cueActions
            } else if self.isPartCountForCue {
                return .partCountForCue
            } else if self.isPart {
                return .part
            } else if self.isPartEffects {
                return .partEffects
            } else if self.isPartLinks {
                return .partLinks
            } else if self.isPartActions {
                return .partActions
            } else {
                return .unknown
            }
        }
    }
    
    // /eos/out/get/cuelist/count
    private var isCueListCount: Bool {
        get {
            return self.addressPattern == "/get/cuelist/count"
        }
    }
    // /eos/out/get/cuelist/1/list/0/13
    private var isCueList: Bool {
        get {
            return self.addressPattern.range(of: "/get/cuelist/[1-9][0-9]{0,3}/list/[0-9][0-9]{0,3}/[1-9][0-9]{0,3}$", options: .regularExpression) != nil
        }
    }
    // /eos/out/get/cuelist/1/links/list/0/2
    private var isCueListLink: Bool {
        get {
            return self.addressPattern.range(of: "/get/cuelist/[1-9][0-9]{0,3}/links/list/[0-9][0-9]{0,3}/[1-9][0-9]{0,3}$", options: .regularExpression) != nil
        }
    }
    // /eos/out/get/cue/1/noparts/count
    private var isCueCountForList: Bool {
        get {
            return self.addressPattern.range(of: "/get/cue/[1-9][0-9]{0,3}/noparts/count", options: .regularExpression) != nil
        }
    }
    // /eos/out/get/cue/1/1/noparts/list/0/31
    private var isCue: Bool {
        get {
            return self.addressPattern.range(of: "/get/cue/[1-9][0-9]{0,3}/((?=.*[1-9])\\d{1,4}(?:\\.\\d{1,3})?(?:(?=.*[1-9])\\d{1,4}(?:\\.\\d{1,3})?)*)/noparts/list/[0-9][0-9]{0,3}/[1-9][0-9]{0,3}", options: .regularExpression) != nil
        }
    }
    // /eos/out/get/cue/1/1/noparts/fx/list/0/2
    private var isCueEffects: Bool {
        get {
            return self.addressPattern.range(of: "/get/cue/[1-9][0-9]{0,3}/((?=.*[1-9])\\d{1,4}(?:\\.\\d{1,3})?(?:(?=.*[1-9])\\d{1,4}(?:\\.\\d{1,3})?)*)/noparts/fx/list/[0-9][0-9]{0,3}/[1-9][0-9]{0,3}", options: .regularExpression) != nil
        }
    }
    // /eos/out/get/cue/1/1/noparts/links/list/0/2
    private var isCueLinks: Bool {
        get {
            return self.addressPattern.range(of: "/get/cue/[1-9][0-9]{0,3}/((?=.*[1-9])\\d{1,4}(?:\\.\\d{1,3})?(?:(?=.*[1-9])\\d{1,4}(?:\\.\\d{1,3})?)*)/noparts/links/list/[0-9][0-9]{0,3}/[1-9][0-9]{0,3}", options: .regularExpression) != nil
        }
    }
    // /eos/out/get/cue/1/1/noparts/actions/list/0/2
    private var isCueActions: Bool {
        get {
            return self.addressPattern.range(of: "/get/cue/[1-9][0-9]{0,3}/((?=.*[1-9])\\d{1,4}(?:\\.\\d{1,3})?(?:(?=.*[1-9])\\d{1,4}(?:\\.\\d{1,3})?)*)/noparts/actions/list/[0-9][0-9]{0,3}/[1-9][0-9]{0,3}", options: .regularExpression) != nil
        }
    }
    // /eos/out/get/cue/1/1/count
    private var isPartCountForCue: Bool {
        get {
            return self.addressPattern.range(of: "/get/cue/[1-9][0-9]{0,3}/((?=.*[1-9])\\d{1,4}(?:\\.\\d{1,3})?(?:(?=.*[1-9])\\d{1,4}(?:\\.\\d{1,3})?)*)/count", options: .regularExpression) != nil
        }
    }
    // /eos/out/get/cue/1/1/1/list/0/31 - Part number must be 1-20.
    private var isPart: Bool {
        get {
            return self.addressPattern.range(of: "/get/cue/[1-9][0-9]{0,3}/((?=.*[1-9])\\d{1,4}(?:\\.\\d{1,3})?(?:(?=.*[1-9])\\d{1,4}(?:\\.\\d{1,3})?)*)/(?:[1-9]|0[1-9]|1[0-9]|20)/list/[0-9][0-9]{0,3}/[1-9][0-9]{0,3}", options: .regularExpression) != nil
        }
    }
    // /eos/out/get/cue/1/1/1/fx/list/0/2
    private var isPartEffects: Bool {
        get {
            return self.addressPattern.range(of: "/get/cue/[1-9][0-9]{0,3}/((?=.*[1-9])\\d{1,4}(?:\\.\\d{1,3})?(?:(?=.*[1-9])\\d{1,4}(?:\\.\\d{1,3})?)*)/(?:[1-9]|0[1-9]|1[0-9]|20)/fx/list/[0-9][0-9]{0,3}/[1-9][0-9]{0,3}", options: .regularExpression) != nil
        }
    }
    // /eos/out/get/cue/1/1/1/links/list/0/2
    private var isPartLinks: Bool {
        get {
            return self.addressPattern.range(of: "/get/cue/[1-9][0-9]{0,3}/((?=.*[1-9])\\d{1,4}(?:\\.\\d{1,3})?(?:(?=.*[1-9])\\d{1,4}(?:\\.\\d{1,3})?)*)/(?:[1-9]|0[1-9]|1[0-9]|20)/links/list/[0-9][0-9]{0,3}/[1-9][0-9]{0,3}", options: .regularExpression) != nil
        }
    }
    // /eos/out/get/cue/1/1/1/actions/list/0/2
    private var isPartActions: Bool {
        get {
            return self.addressPattern.range(of: "/get/cue/[1-9][0-9]{0,3}/((?=.*[1-9])\\d{1,4}(?:\\.\\d{1,3})?(?:(?=.*[1-9])\\d{1,4}(?:\\.\\d{1,3})?)*)/(?:[1-9]|0[1-9]|1[0-9]|20)/actions/list/[0-9][0-9]{0,3}/[1-9][0-9]{0,3}", options: .regularExpression) != nil
        }
    }
}
