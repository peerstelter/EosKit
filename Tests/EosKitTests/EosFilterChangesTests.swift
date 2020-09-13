import Foundation
import OSCKit
import XCTest

@testable import EosKit

final class EosFilterChnagesTests: XCTestCase {
    
    func testEmptyToEmpty() {
        let changes = EosFilterChanges(with: EosOptionChanges(from: [], to: []))
        XCTAssertTrue(changes.add.isEmpty)
        XCTAssertTrue(changes.remove.isEmpty)
    }
    
    func testCuesToCues() {
        let changes = EosFilterChanges(with: EosOptionChanges(from: [.cues], to: [.cues]))
        XCTAssertTrue(changes.add.isEmpty)
        XCTAssertTrue(changes.remove.isEmpty)
    }
    
    func testEmptyToCues() {
        let changes = EosFilterChanges(with: EosOptionChanges(from: [], to: [.cues]))
        XCTAssertEqual(changes.add, eosCuesFilters)
        XCTAssertTrue(changes.remove.isEmpty)
    }
    
    func testCuesToEmpty() {
        let changes = EosFilterChanges(with: EosOptionChanges(from: [.cues], to: []))
        XCTAssertTrue(changes.add.isEmpty)
        XCTAssertEqual(changes.remove, eosCuesFilters)
    }
    
    func testEmptyToCuesAndPatch() {
        let changes = EosFilterChanges(with: EosOptionChanges(from: [], to: [.cues, .patch]))
        let arguments = eosCuesFilters.union(eosPatchFilters)
        XCTAssertEqual(changes.add, arguments)
        XCTAssertTrue(changes.remove.isEmpty)
    }
    
    func testCuesAndPatchToEmpty() {
        let changes = EosFilterChanges(with: EosOptionChanges(from: [.cues, .patch], to: []))
        let arguments = eosCuesFilters.union(eosPatchFilters)
        XCTAssertEqual(changes.remove, arguments)
        XCTAssertTrue(changes.add.isEmpty)
    }
    
    func testCuesToPatch() {
        let changes = EosFilterChanges(with: EosOptionChanges(from: [.cues], to: [.patch]))
        XCTAssertFalse(changes.add.isEmpty)
        XCTAssertFalse(changes.remove.isEmpty)
        XCTAssertEqual(changes.add, eosPatchFilters)
        XCTAssertEqual(changes.remove, eosCuesFilters)
    }

    func testPatchToCues() {
        let changes = EosFilterChanges(with: EosOptionChanges(from: [.patch], to: [.cues]))
        XCTAssertFalse(changes.add.isEmpty)
        XCTAssertFalse(changes.remove.isEmpty)
        XCTAssertEqual(changes.add, eosCuesFilters)
        XCTAssertEqual(changes.remove, eosPatchFilters)
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
