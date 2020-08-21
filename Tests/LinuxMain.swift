import XCTest

import EosKitTests

var tests = [XCTestCaseEntry]()
tests += ConsoleTypeTests.allTests()
tests += EosBrowserTests.allTests()
tests += EosConsoleTests.allTests()
tests += EosKitTests.allTests()
XCTMain(tests)
