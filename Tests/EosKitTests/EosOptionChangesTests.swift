import Foundation
import OSCKit
import XCTest

@testable import EosKit

final class EosOptionChnagesTests: XCTestCase {
    
    func testEmptyToEmpty() {
        let changes = EosOptionChanges(from: [], to: [])
        XCTAssertTrue(changes.add.isEmpty)
        XCTAssertTrue(changes.remove.isEmpty)
    }
    
    func testCuesToCues() {
        let changes = EosOptionChanges(from: [.cues], to: [.cues])
        XCTAssertTrue(changes.add.isEmpty)
        XCTAssertTrue(changes.remove.isEmpty)
    }
    
    func testEmptyToCues() {
        let changes = EosOptionChanges(from: [], to: [.cues])
        XCTAssertEqual(changes.add, [.cues])
        XCTAssertTrue(changes.remove.isEmpty)
    }
    
    func testCuesToEmpty() {
        let changes = EosOptionChanges(from: [.cues], to: [])
        XCTAssertTrue(changes.add.isEmpty)
        XCTAssertEqual(changes.remove, [.cues])
    }
    
    func testEmptyToCuesAndPatch() {
        let changes = EosOptionChanges(from: [], to: [.cues, .patch])
        XCTAssertEqual(changes.add, [.cues, .patch])
        XCTAssertTrue(changes.remove.isEmpty)
    }
    
    func testCuesAndPatchToEmpty() {
        let changes = EosOptionChanges(from: [.cues, .patch], to: [])
        XCTAssertEqual(changes.remove, [.cues, .patch])
        XCTAssertTrue(changes.add.isEmpty)
    }
    
    func testCuesToPatch() {
        let changes = EosOptionChanges(from: [.cues], to: [.patch])
        XCTAssertFalse(changes.add.isEmpty)
        XCTAssertFalse(changes.remove.isEmpty)
        XCTAssertEqual(changes.add, [.patch])
        XCTAssertEqual(changes.remove, [.cues])
    }

    func testPatchToCues() {
        let changes = EosOptionChanges(from: [.patch], to: [.cues])
        XCTAssertFalse(changes.add.isEmpty)
        XCTAssertFalse(changes.remove.isEmpty)
        XCTAssertEqual(changes.add, [.cues])
        XCTAssertEqual(changes.remove, [.patch])
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
