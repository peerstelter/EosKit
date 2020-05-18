import XCTest

import EosKitTests

var tests = [XCTestCaseEntry]()
tests += EosBrowserTests.allTests()
tests += EosKitTests.allTests()
XCTMain(tests)
