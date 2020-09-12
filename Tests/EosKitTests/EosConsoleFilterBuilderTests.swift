import Foundation
import OSCKit
import XCTest

@testable import EosKit

final class EosConsoleFilterBuilderTests: XCTestCase {
    
    func testEmptyToEmpty() {
        let filter = EosConsoleFilterBuilder.filter(from: [], to: [])
        XCTAssertNil(filter.add)
        XCTAssertNil(filter.remove)
    }
    
    func testCuesToCues() {
        let filters = EosConsoleFilterBuilder.filter(from: [.cues], to: [.cues])
        XCTAssertNil(filters.add)
        XCTAssertNil(filters.remove)
    }
    
    func testEmptyToCues() {
        let filters = EosConsoleFilterBuilder.filter(from: [], to: [.cues])
        XCTAssertEqual(filters.add!, eosCuesFilters)
    }
    
    func testCuesToEmpty() {
        let filters = EosConsoleFilterBuilder.filter(from: [.cues], to: [])
        XCTAssertEqual(filters.remove, eosCuesFilters)
    }
    
    func testEmptyToCuesAndPatch() {
        let filters = EosConsoleFilterBuilder.filter(from: [], to: [.cues, .patch])
        let arguments = eosCuesFilters.union(eosPatchFilters)
        XCTAssertEqual(filters.add!, arguments)
    }
    
    func testCuesAndPatchToEmpty() {
        let filters = EosConsoleFilterBuilder.filter(from: [.cues, .patch], to: [])
        let arguments = eosCuesFilters.union(eosPatchFilters)
        XCTAssertEqual(filters.remove!, arguments)
    }
    
    func testCuesToPatch() {
        let filters = EosConsoleFilterBuilder.filter(from: [.cues], to: [.patch])
        XCTAssertNotNil(filters.add)
        XCTAssertNotNil(filters.remove)
        XCTAssertEqual(filters.add!, eosPatchFilters)
        XCTAssertEqual(filters.remove!, eosCuesFilters)
    }

    func testPatchToCues() {
        let filters = EosConsoleFilterBuilder.filter(from: [.patch], to: [.cues])
        XCTAssertNotNil(filters.add)
        XCTAssertNotNil(filters.remove)
        XCTAssertEqual(filters.add!, eosCuesFilters)
        XCTAssertEqual(filters.remove!, eosPatchFilters)
    }
    
    static var allTests = [
        ("testEmptyToEmpty", testEmptyToEmpty,
         "testCuesToCues", testCuesToCues,
         "testEmptyToCues", testEmptyToCues,
         "testCuesToEmpty", testCuesToEmpty,
         "testEmptyToCuesAndPatch", testEmptyToCuesAndPatch,
         "testCuesAndPatchToEmpty", testCuesAndPatchToEmpty,
         "testCuesToPatch", testCuesToPatch,
         "testPatchToCues", testPatchToCues)
    ]
}
