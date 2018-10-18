import XCTest

#if !os(macOS)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(MemoryLeakDetectorTests.allTests),
        testCase(ReferenceIDTests.allTests),
        testCase(ReferencePathNormalizationTests.allTests),
    ]
}
#endif