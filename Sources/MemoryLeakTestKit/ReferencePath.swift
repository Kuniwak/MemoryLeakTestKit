public struct ReferencePath: Hashable {
    public let components: [ReferencePathComponent]


    public var count: Int {
        return self.components.count
    }


    public var description: String {
        return "(root)" + self.components
            .map { $0.description }
            .joined(separator: "")
    }


    public init(components: [ReferencePathComponent]) {
        self.components = components
    }


    public init(identifiablePath: IdentifiableReferencePath) {
        let hints = identifiablePath
            .idComponents
            .map { ReferencePathNormalization.Hint($0.noNormalizedComponent) }

        self.init(components: ReferencePathNormalization.normalize(hints: hints))
    }


    public static let root = ReferencePath(components: [])
}



extension ReferencePath: Comparable {
    public static func <(lhs: ReferencePath, rhs: ReferencePath) -> Bool {
        return lhs.count < rhs.count
    }
}
