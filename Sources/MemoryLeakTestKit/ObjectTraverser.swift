public func traverseObjectWithPath(
    _ target: Any,
    onEnter: ((NotNormalizedReferencePathComponent, Any, [(component: NotNormalizedReferencePathComponent, value: Any)]) -> Void)?,
    onLeave: ((NotNormalizedReferencePathComponent, Any, [(component: NotNormalizedReferencePathComponent, value: Any)]) -> Void)?
) {
    var currentPath: [(component: NotNormalizedReferencePathComponent, value: Any)] = []

    traverseObject(
        target,
        onEnter: { (component, value) in
            currentPath.append((component: component, value: value))
            onEnter?(component, value, currentPath)
        },
        onLeave: { (component, value) in
            onLeave?(component, value, currentPath)
            currentPath.removeLast()
        }
    )
}



public func traverseObject(
    _ target: Any,
    onEnter: ((NotNormalizedReferencePathComponent, Any) -> Void)?,
    onLeave: ((NotNormalizedReferencePathComponent, Any) -> Void)?
) {
    var footprint = Set<ReferenceID>()

    traverseObjectRecursive(
        target,
        footprint: &footprint,
        onEnter: onEnter,
        onLeave: onLeave
    )
}



private func traverseObjectRecursive(
    _ target: Any,
    footprint: inout Set<ReferenceID>,
    onEnter: ((NotNormalizedReferencePathComponent, Any) -> Void)?,
    onLeave: ((NotNormalizedReferencePathComponent, Any) -> Void)?
) {
    // NOTE: Avoid infinite recursions caused by circular references.
    let id = ReferenceID(of: target)
    if !footprint.contains(id) {
        footprint.insert(id)

        let mirror = Mirror(reflecting: target)
        mirror.children.enumerated().forEach { indexAndChild in
            let (index, (label: label, value: value)) = indexAndChild

            let component = NotNormalizedReferencePathComponent(
                isCollection: mirror.displayStyle == .collection,
                index: index,
                label: label
            )

            onEnter?(component, value)

            traverseObjectRecursive(
                value,
                footprint: &footprint,
                onEnter: onEnter,
                onLeave: onLeave
            )

            onLeave?(component, value)
        }
    }
}
