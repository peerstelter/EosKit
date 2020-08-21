import Foundation
import XCTest
import OSCKit
import NetUtils
@testable import EosKit

final class EosConsoleTests: XCTestCase {

    private var console: EosConsole?
    private var mockConsole: MockConnectableEosConsole?

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testConnect() {
        weak var promise = expectation(description: "The console can not be connected to.")
        
        let interface = Interface.allInterfaces().first(where: { $0.family == .ipv4 })
    
        mockConsole = MockConnectableEosConsole(type: .eos)
        mockConsole?.start()
        
        console = EosConsole(name: "EosKit", type: .eos, host: interface!.address!)
        
        let mock = MockEosConsoleDelegate(callback: { console in
                promise?.fulfill()
                promise = nil
        })
        console!.delegate = mock
        _ = console!.connect()
        
        // Wait for the expectation to be fullfilled, or time out
        // after 5 seconds. This is where the test runner will pause.
        waitForExpectations(timeout: 5, handler: nil)
    }

}
