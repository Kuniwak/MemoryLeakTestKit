public struct IdentifiableReferencePath: Hashable {
    public let rootID: ReferenceID
    public let idComponents: [IdentifiableReferencePathComponent]


    public var isRoot: Bool {
        return self.idComponents.isEmpty
    }


    public init(rootID: ReferenceID, idComponents: [IdentifiableReferencePathComponent]) {
        self.rootID = rootID
        self.idComponents = idComponents
    }


    public init<Pairs: Sequence>(
        root: Any, componentAndValuePairs: Pairs
    ) where Pairs.Element == (component: NotNormalizedReferencePathComponent, value: Any) {
        self.init(
            rootID: ReferenceID(of: root),
            idComponents: componentAndValuePairs.map { pair in
                let (component: component, value: value) = pair
                return IdentifiableReferencePathComponent(
                    id: ReferenceID(of: value),
                    typeName:  TypeName(of: value),
                    noNormalizedComponent: component
                )
            }
        )
    }
}
