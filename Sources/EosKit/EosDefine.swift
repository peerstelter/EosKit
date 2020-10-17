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

internal let eosSystemFilters: Set = ["/eos/out/get/version",
                                      "/eos/out/ping",
                                      "/eos/out/filter/add",
                                      "/eos/out/filter/remove"]

internal let eosPatchFilters: Set = ["/eos/out/get/patch/count",
                                     "/eos/out/get/patch/*/*/list/*/*",
                                     "/eos/out/get/patch/*/*/notes"]

// TODO: Comment out the noparts methods if we are no longer using them in the cue sync process.
internal let eosCuesFilters: Set = ["/eos/out/get/cuelist/count",
                                   "/eos/out/get/cuelist/*/list/*/*",
                                   "/eos/out/get/cuelist/*/links/list/*/*",
                                   "/eos/out/get/cue/*/count",
                                   "/eos/out/get/cue/*/noparts/count",
                                   "/eos/out/get/cue/*/*/noparts/list/*/*",
                                   "/eos/out/get/cue/*/*/noparts/fx/list/*/*",
                                   "/eos/out/get/cue/*/*/noparts/links/list/*/*",
                                   "/eos/out/get/cue/*/*/noparts/actions/list/*/*",
                                   "/eos/out/get/cue/*/*/count",
                                   "/eos/out/get/cue/*/*/*/list/*/*",
                                   "/eos/out/get/cue/*/*/*/fx/list/*/*",
                                   "/eos/out/get/cue/*/*/*/links/list/*/*",
                                   "/eos/out/get/cue/*/*/*/actions/list/*/*"]

internal let eosGroupsFilters: Set = ["/eos/out/get/group/count",
                                      "/eos/get/group/*/list/*/*",
                                      "/eos/get/group/*/channels/list/*/*"]

internal let eosMacrosFilters: Set = ["/eos/out/get/macro/count",
                                      "/eos/get/macro/*/list/*/*",
                                      "/eos/get/macro/*/text/list/*/*"]

internal let eosSubsFilters: Set = ["/eos/get/sub/count",
                                    "/eos/get/sub/*/list/*/*",
                                    "/eos/get/sub/*/fx/list/*/*"]

internal let eosPresetsFilters: Set = ["/eos/get/preset/count",
                                       "/eos/get/preset/*/list/*/*",
                                       "/eos/get/preset/*/channels/list/*/*",
                                       "/eos/get/preset/*/byType/list/*/*",
                                       "/eos/get/preset/*/fx/list/*/*"]

internal let eosIntensityPalettesFilters: Set = ["/eos/get/ip/count",
                                                 "/eos/get/ip/*/list/*/*",
                                                 "/eos/get/ip/*/channels/list/*/*",
                                                 "/eos/get/ip/*/byType/list/*/*"]

internal let eosFocusPalettesFilters: Set = ["/eos/get/fp/count",
                                             "/eos/get/fp/*/list/*/*",
                                             "/eos/get/fp/*/channels/list/*/*",
                                             "/eos/get/fp/*/byType/list/*/*"]

internal let eosColorPalettesFilters: Set = ["/eos/get/cp/count",
                                             "/eos/get/cp/*/list/*/*",
                                             "/eos/get/cp/*/channels/list/*/*",
                                             "/eos/get/cp/*/byType/list/*/*"]

internal let eosBeamPalettesFilters: Set = ["/eos/get/bp/count",
                                            "/eos/get/bp/*/list/*/*",
                                            "/eos/get/bp/*/channels/list/*/*",
                                            "/eos/get/bp/*/byType/list/*/*"]

internal let eosCurvesFilters: Set = ["/eos/get/curve/count",
                                      "/eos/get/curve/*/list/*/*"]

internal let eosEffectsFilters: Set = ["/eos/get/fx/count",
                                       "/eos/get/fx/*/list/*/*"]

internal let eosSnapshotsFilters: Set = ["/eos/get/snap/count",
                                         "/eos/get/snap/*/list/*/*"]

internal let eosPixelMapsFilters: Set = ["/eos/get/pixmap/count",
                                         "/eos/get/pixmap/*/list/*/*",
                                         "/eos/get/pixmap/*/channels/list/*/*"]

internal let eosMagicSheetsFilters: Set = ["/eos/get/ms/count",
                                           "/eos/get/ms/*/list/*/*"]

internal let eosSetupsFilters: Set = ["/eos/get/setup/list/*/*"]

internal let eosPlaybackFilters: Set = ["/eos/out/event/cue/*/*/fire"]
