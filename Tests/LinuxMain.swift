import XCTest

import MemoryLeakTestKitTests

var tests = [XCTestCaseEntry]()
tests += MemoryLeakTestKitTests.allTests()
XCTMain(tests)