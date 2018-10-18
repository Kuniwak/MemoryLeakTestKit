import Foundation
import XCTest
import MemoryLeakTestKit



class MemoryLeakDetectorTests: XCTestCase {
    func testMemoryLeak() {
    	typealias TestCase = (
            build: () -> Any,
            expected: MemoryLeakReport
    	)

    	let testCases: [UInt: TestCase] = [
    	    #line: ( // No circulars
                build: { () -> Node in
                    return Node(linkedNodes: [])
                },
                expected: MemoryLeakReport(
                    leakedObjects: []
                )
    	    ),
            #line: ( // Single direct circular
                build: { () -> Node in
                    let node = Node(linkedNodes: [])
                    node.linkedNodes = [node]
                    return node
                },
                expected: MemoryLeakReport(
                    leakedObjects: [
                        LeakedObject(
                            objectDescription: "Node",
                            typeName: TypeName(text: "Node"),
                            location: ReferencePath.root,
                            circularPaths: [
                                CircularReferencePath(
                                    end: .root(TypeName(text: "Node")),
                                    components: ArrayLongerThan1<ReferencePathComponent>([
                                        .label("linkedNodes"),
                                        .index(0),
                                    ])!
                                ),
                            ]
                        ),
                    ]
                )
            ),
            #line: ( // Single indirect circular
                build: { () -> Node in
                    let indirectNode = Node(linkedNodes: [])
                    let node = Node(linkedNodes: [indirectNode])
                    indirectNode.linkedNodes = [node]
                    return node
                },
                expected: MemoryLeakReport(
                    leakedObjects: [
                        LeakedObject(
                            objectDescription: "Node",
                            typeName: TypeName(text: "Node"),
                            location: ReferencePath.root,
                            circularPaths: [
                                CircularReferencePath(
                                    end: .root(TypeName(text: "Node")),
                                    components: ArrayLongerThan1([
                                        .label("linkedNodes"),
                                        .index(0),
                                        .label("linkedNodes"),
                                        .index(0),
                                    ])!
                                )
                            ]
                        ),
                        LeakedObject(
                            objectDescription: "Node",
                            typeName: TypeName(text: "Node"),
                            location: ReferencePath(components: [
                                .label("linkedNodes"),
                                .index(0),
                            ]),
                            circularPaths: []
                        ),
                    ]
                )
            ),
            #line: ( // Both direct and indirect circulars
                build: { () -> Node in
                    let indirectNode = Node(linkedNodes: [])
                    let node = Node(linkedNodes: [indirectNode])
                    indirectNode.linkedNodes = [node, indirectNode]
                    return node
                },
                expected: MemoryLeakReport(
                    leakedObjects: [
                        LeakedObject(
                            objectDescription: "Node",
                            typeName: TypeName(text: "Node"),
                            location: ReferencePath.root,
                            circularPaths: [
                                CircularReferencePath(
                                    end: .root(TypeName(text: "Node")),
                                    components: ArrayLongerThan1([
                                        .label("linkedNodes"),
                                        .index(0),
                                        .label("linkedNodes"),
                                        .index(0),
                                    ])!
                                ),
                            ]
                        ),
                        LeakedObject(
                            objectDescription: "Node",
                            typeName: TypeName(text: "Node"),
                            location: ReferencePath(components: [
                                .label("linkedNodes"),
                                .index(0),
                            ]),
                            circularPaths: [
                                CircularReferencePath(
                                    end: .intermediate(TypeName(text: "Node")),
                                    components: ArrayLongerThan1([
                                        .label("linkedNodes"),
                                        .index(1),
                                    ])!
                                ),
                            ]
                        ),
                    ]
                )
            ),
            #line: ( // Lazy
                build: { () -> LazyCircularNode in
                    let node = LazyCircularNode()
                    _ = node.indirect
                    return node
                },
                expected: MemoryLeakReport(
                    leakedObjects: [
                        LeakedObject(
                            objectDescription: "LazyCircularNode",
                            typeName: TypeName(text: "LazyCircularNode"),
                            location: ReferencePath.root,
                            circularPaths: [
                                CircularReferencePath(
                                    end: .root(TypeName(text: "LazyCircularNode")),
                                    components: ArrayLongerThan1([
                                        .label("indirect"),
                                        .label("value"),
                                    ])!
                                ),
                            ]
                        ),
                        LeakedObject(
                            objectDescription: "Indirect",
                            typeName: TypeName(text: "Indirect"),
                            location: ReferencePath(components: [
                                .label("indirect"),
                            ]),
                            circularPaths: []
                        ),
                    ]
                )
            ),
            #line: ( // No circular references but outer owner exists
                build: { () -> Node in
                    let node = Node(linkedNodes: [])
                    var anonymous: (() -> Void)?

                    anonymous = {
                        _ = node
                        anonymous!()
                    }

                    return node
                },
                expected: MemoryLeakReport(
                    leakedObjects: [
                        LeakedObject(
                            objectDescription: "Node",
                            typeName: TypeName(text: "Node"),
                            location: ReferencePath.root,
                            circularPaths: []
                        )
                    ]
                )
            ),
            #line: ( // Circular references but anonymous instances at end
                build: { () -> Node in
                    let node = Node(linkedNodes: [])

                    ReferenceOwner.global.own(node)

                    return Node(linkedNodes: [node])
                },
                expected: MemoryLeakReport(
                    leakedObjects: [
                        LeakedObject(
                            objectDescription: "Node",
                            typeName: TypeName(text: "Node"),
                            location: ReferencePath(components: [
                                .label("linkedNodes"),
                                .index(0),
                            ]),
                            circularPaths: []
                        )
                    ]
                )
            ),
    	]

    	testCases.forEach { tuple in
    	    let (line, (build: build, expected: expected)) = tuple

            let memoryLeakHints = detectLeaks(by: build)

            XCTAssertEqual(
                memoryLeakHints, expected,
                differenceMemoryLeakReport(between: expected, and: memoryLeakHints),
                line: line
            )
    	}
    }



    private final class Node: CustomStringConvertible {
        var linkedNodes: [Node]


        init(linkedNodes: [Node]) {
            self.linkedNodes = linkedNodes
        }


        var description: String {
            return "Node"
        }
    }



    private final class LazyCircularNode: CustomStringConvertible {
        lazy var indirect: Indirect = Indirect(value: self)


        final class Indirect: CustomStringConvertible {
            let value: LazyCircularNode


            init(value: LazyCircularNode) {
                self.value = value
            }


            var description: String {
                return "Indirect"
            }
        }


        var description: String {
            return "LazyCircularNode"
        }
    }



    public final class ReferenceOwner {
        private var owned: [Any] = []
        private init() {}


        public func own(_ any: Any) {
            self.owned.append(any)
        }


        public static let global = ReferenceOwner()
    }



    private func differenceMemoryLeakReport(between a: MemoryLeakReport, and b: MemoryLeakReport) -> String {
        let missingLeakedObjects = sections(a.leakedObjects.subtracting(b.leakedObjects)
            .map { $0.descriptionLines })

        let extraLeakedObjects = sections(b.leakedObjects.subtracting(a.leakedObjects)
            .map { $0.descriptionLines })

        return format(verticalPadding(sections([
            (name: "Missing leaked objects", body: missingLeakedObjects),
            (name: "Extra leaked objects", body: extraLeakedObjects),
        ])))
    }


    static let allTests: [(String, (MemoryLeakDetectorTests) -> () throws -> Void)] = [
        ("testMemoryLeak", testMemoryLeak),
    ]
}