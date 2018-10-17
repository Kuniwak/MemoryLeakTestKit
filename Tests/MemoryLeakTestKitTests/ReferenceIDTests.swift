import XCTest
import MemoryLeakTestKit



class ReferenceIDTests: XCTestCase {
    func testEquatable() {
    	typealias TestCase = (
			ReferenceID,
			ReferenceID,
			expected: Bool
    	)

    	let testCases: [UInt: TestCase] = [
    	    #line: (
				ReferenceID(of: 0),
				ReferenceID(of: 0),
                expected: false
    	    ),
			#line: {
				let object1 = NSObject()
                let object2 = NSObject()
				return (
					ReferenceID(of: object1),
					ReferenceID(of: object2),
					expected: false
				)
			}(),
			#line: {
				let object = NSObject()
				return (
					ReferenceID(of: object),
					ReferenceID(of: object),
					expected: true
				)
			}()
    	]

    	testCases.forEach { tuple in
    	    let (line, (a, b, expected: expected)) = tuple

			XCTAssertEqual(a == b, expected, line: line)
    	}
    }


    static let allTests: [(String, (ReferenceIDTests) -> () throws -> Void)] = [
        ("testEquatable", testEquatable),
    ]
}