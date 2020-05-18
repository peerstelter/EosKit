import Foundation
import XCTest
import OSCKit
@testable import EosKit

final class EosBrowserTests: XCTestCase {
    
    private var browser: EosBrowser?
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        browser = EosBrowser()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        browser!.stop()
        browser = nil
    }
    
    func testDiscovery() {
        weak var promise = expectation(description: "No reply from an Eos console")
        
        let mock = MockEosBrowserDelegate(callback: {
            promise!.fulfill()
            promise = nil
        })
        browser!.delegate = mock
        browser!.start()
        // Wait for the expectation to be fullfilled, or time out
        // after 5 seconds. This is where the test runner will pause.
        waitForExpectations(timeout: 5, handler: nil)
        
    }
    
    func testConsoleInfo() {
        weak var promise = expectation(description: "No reply")
        
        let mock = MockEosBrowserDelegate(callback: {
            promise!.fulfill()
            promise = nil
        })
        browser!.delegate = mock
        browser!.start()
        // Wait for the expectation to be fullfilled, or time out
        // after 5 seconds. This is where the test runner will pause.
        waitForExpectations(timeout: 5, handler: nil)
    }
    

    static var allTests = [
        ("testDiscovery", testDiscovery),
        ("testConsoleInfo", testConsoleInfo),
    ]
}
