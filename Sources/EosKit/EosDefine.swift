//
//  EosDefine.swift
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

internal typealias EosKitCompletionHandler = (OSCMessage) -> Void

// MARK:- Heartbeat
internal let EosConsoleHeartbeatMaxAttempts: Int = 3
internal let EosConsoleHeartbeatInterval: TimeInterval = 5
internal let EosConsoleHeartbeatFailureInterval: TimeInterval = 1
internal let eosHeartbeatString = "EosKit Heartbeat"

// MARK:- OSC Address Patterns
internal let eosDiscoveryRequest = "/etc/discovery/request"
internal let eosDiscoveryReply = "/etc/discovery/reply"
internal let eosFiltersRemove = "/eos/filter/remove"
internal let eosFiltersAdd = "/eos/filter/add"
internal let eosRequestPrefix = "/eos"
internal let eosReplyPrefix = "/eos/out"
internal let eosPingRequest = "/ping"

internal let eosSystemFilters: Set = ["/get/version",
                                      "/ping",
                                      "/filter/add",
                                      "/filter/remove"]

internal let eosPatchFilters: Set = ["/get/patch/count",
                                     "/get/patch/*/*/list/*/*",
                                     "/get/patch/*/*/notes"]

// TODO: Comment out the noparts methods if we are no longer using them in the cue sync process.
internal let eosCueFilters: Set = ["/get/cuelist/count",
                                   "/get/cuelist/*/list/*/*",
                                   "/get/cuelist/*/links/list/*/*",
                                   "/get/cue/*/count",
                                   "/get/cue/*/noparts/count",
                                   "/get/cue/*/*/noparts/list/*/*",
                                   "/get/cue/*/*/noparts/fx/list/*/*",
                                   "/get/cue/*/*/noparts/links/list/*/*",
                                   "/get/cue/*/*/noparts/actions/list/*/*",
                                   "/get/cue/*/*/count",
                                   "/get/cue/*/*/*/list/*/*",
                                   "/get/cue/*/*/*/fx/list/*/*",
                                   "/get/cue/*/*/*/links/list/*/*",
                                   "/get/cue/*/*/*/actions/list/*/*"]

internal let eosGroupFilters: Set = ["/get/group/count",
                                      "/get/group/*/list/*/*",
                                      "/get/group/*/channels/list/*/*"]

internal let eosMacroFilters: Set = ["/get/macro/count",
                                      "/get/macro/*/list/*/*",
                                      "/get/macro/*/text/list/*/*"]

internal let eosSubFilters: Set = ["/get/sub/count",
                                   "/get/sub/*/list/*/*",
                                   "/get/sub/*/fx/list/*/*"]

internal let eosPresetFilters: Set = ["/get/preset/count",
                                      "/get/preset/*/list/*/*",
                                      "/get/preset/*/channels/list/*/*",
                                      "/get/preset/*/byType/list/*/*",
                                      "/get/preset/*/fx/list/*/*"]

internal let eosIntensityPaletteFilters: Set = ["/get/ip/count",
                                                "/get/ip/*/list/*/*",
                                                "/get/ip/*/channels/list/*/*",
                                                "/get/ip/*/byType/list/*/*"]

internal let eosFocusPaletteFilters: Set = ["/get/fp/count",
                                            "/get/fp/*/list/*/*",
                                            "/get/fp/*/channels/list/*/*",
                                            "/get/fp/*/byType/list/*/*"]

internal let eosColorPaletteFilters: Set = ["/get/cp/count",
                                            "/get/cp/*/list/*/*",
                                            "/get/cp/*/channels/list/*/*",
                                            "/get/cp/*/byType/list/*/*"]

internal let eosBeamPaletteFilters: Set = ["/get/bp/count",
                                           "/get/bp/*/list/*/*",
                                           "/get/bp/*/channels/list/*/*",
                                           "/get/bp/*/byType/list/*/*"]

internal let eosCurveFilters: Set = ["/get/curve/count",
                                     "/get/curve/*/list/*/*"]

internal let eosEffectFilters: Set = ["/get/fx/count",
                                      "/get/fx/*/list/*/*"]

internal let eosSnapshotFilters: Set = ["/get/snap/count",
                                        "/get/snap/*/list/*/*"]

internal let eosPixelMapFilters: Set = ["/get/pixmap/count",
                                        "/get/pixmap/*/list/*/*",
                                        "/get/pixmap/*/channels/list/*/*"]

internal let eosMagicSheetFilters: Set = ["/get/ms/count",
                                          "/get/ms/*/list/*/*"]

internal let eosSetupFilters: Set = ["/get/setup/list/*/*"]

internal let eosPlaybackFilters: Set = ["/event/cue/*/*/fire"]
