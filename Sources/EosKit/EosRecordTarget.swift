//
//  EosRecordTarget.swift
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

public enum EosRecordTarget: Int {
    case patch
    case cueList
    case cue
    case group
    case macro
    case sub
    case preset
    case intensityPalette
    case focusPalette
    case colorPalette
    case beamPalette
    case curve
    case effect
    case snapshot
    case pixelMap
    case magicSheet
    case setup
    
    var filters: Set<String> {
        switch self {
        case .patch: return eosPatchFilters
        case .cueList: return eosCueListFilters
        case .cue: return eosCueNoPartsFilters
        case .group: return eosGroupFilters
        case .macro: return eosMacroFilters
        case .sub: return eosSubFilters
        case .preset: return eosPresetFilters
        case .intensityPalette: return eosIntensityPaletteFilters
        case .focusPalette: return eosFocusPaletteFilters
        case .colorPalette: return eosColorPaletteFilters
        case .beamPalette: return eosBeamPaletteFilters
        case .curve: return eosCurveFilters
        case .effect: return eosEffectFilters
        case .snapshot: return eosSnapshotFilters
        case .pixelMap: return eosPixelMapFilters
        case .magicSheet: return eosMagicSheetFilters
        case .setup: return eosSetupFilters
        }
    }
    
    var part: String {
        switch self {
        case .patch: return "patch"
        case .cueList: return "cuelist"
        case .cue: return "cue"
        case .group: return "group"
        case .macro: return "macro"
        case .sub: return "sub"
        case .preset: return "preset"
        case .intensityPalette: return "ip"
        case .focusPalette: return "fp"
        case .colorPalette: return "cp"
        case .beamPalette: return "bp"
        case .curve: return "curve"
        case .effect: return "fx"
        case .snapshot: return "snap"
        case .pixelMap: return "pixmap"
        case .magicSheet: return "ms"
        case .setup: return "setup"
        }
    }
    
}
