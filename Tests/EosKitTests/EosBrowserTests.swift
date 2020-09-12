import Foundation
import XCTest
import OSCKit
import NetUtils
@testable import EosKit

final class EosBrowserTests: XCTestCase {
    
    private var browser: EosBrowser?
    private var console: MockDiscoverableEosConsole?
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        browser = EosBrowser()
        console = MockDiscoverableEosConsole()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        browser?.stop()
        browser = nil
        console?.stop()
        console = nil
    }
    
    func testDiscovery() {
        weak var promise = expectation(description: "No Eos consoles discovered.")
        console?.start()
        
        let mock = MockEosBrowserDelegate(callback: { _ in
            promise?.fulfill()
            promise = nil
        })
        browser!.delegate = mock
        browser!.start()
        // Wait for the expectation to be fullfilled, or time out
        // after 5 seconds. This is where the test runner will pause.
        waitForExpectations(timeout: 5, handler: nil)
        
    }
    
    func testInterfacesByName() {
        weak var promise = expectation(description: "No reply from console on specified interface by name.")
        console?.start()
        
        var interfaces: [String] = []
        for interface in Interface.allInterfaces() where interface.family == .ipv4 && interface.broadcastAddress != nil {
            interfaces.append(interface.name)
        }
        browser = EosBrowser(port: 24601, interfaces: interfaces)
        let mock = MockEosBrowserDelegate(callback: { _ in
            promise?.fulfill()
            promise = nil
        })
        browser!.delegate = mock
        browser!.start()
        // Wait for the expectation to be fullfilled, or time out
        // after 5 seconds. This is where the test runner will pause.
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testInterfacesByAddress() {
        weak var promise = expectation(description: "No reply from console on specified interface by address.")
        console?.start()
        
        var interfaces: [String] = []
        for interface in Interface.allInterfaces() where interface.family == .ipv4 && interface.broadcastAddress != nil {
            interfaces.append(interface.address!)
        }
        browser = EosBrowser(port: 24601, interfaces: interfaces)
        let mock = MockEosBrowserDelegate(callback: { _ in
            promise?.fulfill()
            promise = nil
        })
        browser!.delegate = mock
        browser!.start()
        // Wait for the expectation to be fullfilled, or time out
        // after 5 seconds. This is where the test runner will pause.
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testReplyMessage() {
        weak var promise = expectation(description: "No reply message from console.")
        console?.start()
        
        let mock = MockEosBrowserDelegate(callback: { console in
            if console.type != .unknown {
                promise?.fulfill()
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
    
    func testConsoleInfo() {
        
        let interface = Interface.allInterfaces().first(where: { $0.family == .ipv4 && $0.broadcastAddress != nil })
        browser = EosBrowser(interfaces: [interface!.address!])
        
        weak var promise = expectation(description: "The console info does not match expectations.")
        let name = "Test"
        let type = EosConsoleType.ion
        
        console = MockDiscoverableEosConsole(name: name, type: type)
        console?.start()
        
        let mock = MockEosBrowserDelegate(callback: { console in
            print(console.name)
            if console.name == name && console.type == type && console.interface == interface?.name {
                promise?.fulfill()
                promise = nil
            }
        })
        
        browser!.delegate = mock
        browser!.start()
        // Wait for the expectation to be fullfilled, or time out
        // after 5 seconds. This is where the test runner will pause.
        waitForExpectations(timeout: 5, handler: nil)
    }
    

    static var allTests = [
        ("testDiscovery", testDiscovery),
        ("testInterfacesByName", testInterfacesByName),
        ("testInterfacesByAddress", testInterfacesByAddress),
        ("testReplyMessage", testReplyMessage),
        ("testConsoleInfo", testConsoleInfo)
    ]
}
