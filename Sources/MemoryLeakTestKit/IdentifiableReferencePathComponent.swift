public struct IdentifiableReferencePathComponent: Hashable {
    public let noNormalizedComponent: NotNormalizedReferencePathComponent
    public let typeName: TypeName
    private let id: ReferenceID


    public var hashValue: Int {
        return self.id.hashValue
    }


    public init(id: ReferenceID, typeName: TypeName, noNormalizedComponent: NotNormalizedReferencePathComponent) {
        self.id = id
        self.typeName = typeName
        self.noNormalizedComponent = noNormalizedComponent
    }


    public func isIdentified(by id: ReferenceID) -> Bool {
        return self.id == id
    }


    public static func ==(lhs: IdentifiableReferencePathComponent, rhs: IdentifiableReferencePathComponent) -> Bool {
        return lhs.id == rhs.id
    }
}
