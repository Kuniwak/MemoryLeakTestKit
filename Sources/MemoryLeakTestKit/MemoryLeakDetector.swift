import Foundation



public func detectLeaks<T>(by build: () -> T) -> MemoryLeakReport {
    let releasedWeakMap = autoreleasepool { () -> [ReferenceID: Reference] in
        return createWeakMap(from: build())
    }

    return MemoryLeakReport(references: releasedWeakMap.values)
}



public func detectLeaks<T>(by build: (@escaping (T) -> Void) -> Void, _ callback: @escaping (MemoryLeakReport) -> Void) {
    build { target in
        let releasedWeakMap = autoreleasepool { () -> [ReferenceID: Reference] in
            return createWeakMap(from: target)
        }

        callback(MemoryLeakReport(references: releasedWeakMap.values))
    }
}



public func createWeakMap<T>(from target: T) -> [ReferenceID: Reference] {
    var result = [
        ReferenceID(of: target): Reference(
            target,
            foundLocations: ArrayLongerThan1<IdentifiableReferencePath>(
                prefix: IdentifiableReferencePath(root: target, componentAndValuePairs: []), []
            )
        )
    ]

    traverseObjectWithPath(
        target,
        onEnter: { (_, value, path) in
            let childReferenceID = ReferenceID(of: value)

            if let visitedReference = result[childReferenceID] {
                visitedReference.found(location: .init(
                    root: target,
                    componentAndValuePairs: path
                ))
            }
            else {
                result[childReferenceID] = Reference(
                    value,
                    foundLocations: ArrayLongerThan1(
                        prefix: IdentifiableReferencePath(
                            root: target,
                            componentAndValuePairs: path
                        ),
                        []
                    )
                )
            }
        },
        onLeave: nil
    )

    return result
}
