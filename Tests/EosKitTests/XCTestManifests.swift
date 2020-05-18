import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(EosBrowserTests.allTests),
        testCase(EosKitTests.allTests),
    ]
}
#endif
