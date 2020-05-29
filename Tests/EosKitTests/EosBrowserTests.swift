import Foundation
import XCTest
import OSCKit
import NetUtils
@testable import EosKit

final class EosBrowserTests: XCTestCase {
    
    private var browser: EosBrowser?
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        browser = EosBrowser(port: 24601)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        browser!.stop()
        browser = nil
    }
    
    func testDiscovery() {
        weak var promise = expectation(description: "No reply from an Eos console")
        
        let mock = MockEosBrowserDelegate(callback: { _ in
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
        
        let mock = MockEosBrowserDelegate(callback: { _ in
            promise!.fulfill()
            promise = nil
        })
        browser!.delegate = mock
        browser!.start()
        // Wait for the expectation to be fullfilled, or time out
        // after 5 seconds. This is where the test runner will pause.
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testInterfacesByName() {
        weak var promise = expectation(description: "No reply")
        var interfaces: [String] = []
        for interface in Interface.allInterfaces() where interface.family == .ipv4 && interface.broadcastAddress != nil {
            interfaces.append(interface.name)
        }
        browser = EosBrowser(port: 24601, interfaces: interfaces)
        let mock = MockEosBrowserDelegate(callback: { _ in
            promise!.fulfill()
            promise = nil
        })
        browser!.delegate = mock
        browser!.start()
        // Wait for the expectation to be fullfilled, or time out
        // after 5 seconds. This is where the test runner will pause.
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testInterfacesByAddress() {
        weak var promise = expectation(description: "No reply")
        var interfaces: [String] = []
        for interface in Interface.allInterfaces() where interface.family == .ipv4 && interface.broadcastAddress != nil {
            interfaces.append(interface.address!)
        }
        browser = EosBrowser(port: 24601, interfaces: interfaces)
        let mock = MockEosBrowserDelegate(callback: { _ in
            promise!.fulfill()
            promise = nil
        })
        browser!.delegate = mock
        browser!.start()
        // Wait for the expectation to be fullfilled, or time out
        // after 5 seconds. This is where the test runner will pause.
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testResponseMessage() {
        weak var promise = expectation(description: "No reply")
        browser = EosBrowser()
        let mock = MockEosBrowserDelegate(callback: { console in
            if console.type != .unknown {
                promise!.fulfill()
                promise = nil
            }
        })
        browser!.delegate = mock
        browser!.start()
        // Wait for the expectation to be fullfilled, or time out
        // after 5 seconds. This is where the test runner will pause.
        waitForExpectations(timeout: 5, handler: nil)
        browser?.stop()
    }
    

    static var allTests = [
        ("testDiscovery", testDiscovery),
        ("testConsoleInfo", testConsoleInfo),
        ("testInterfacesByName", testInterfacesByName),
        ("testInterfacesByAddress", testInterfacesByAddress)
    ]
}
