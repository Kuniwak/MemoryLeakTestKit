public class Reference {
    private let value: WeakOrNotReferenceType
    private let id: ReferenceID

    public let destinationTypeName: TypeName
    public let destinationObjectDescription: String
    public var foundLocations: ArrayLongerThan1<IdentifiableReferencePath>


    public init(
        value: WeakOrNotReferenceType,
        id: ReferenceID,
        typeName: TypeName,
        description: String,
        foundLocations: ArrayLongerThan1<IdentifiableReferencePath>
    ) {
        self.value = value
        self.id = id
        self.destinationTypeName = typeName
        self.destinationObjectDescription = description
        self.foundLocations = foundLocations
    }


    public convenience init(_ target: Any, foundLocations: ArrayLongerThan1<IdentifiableReferencePath>) {
        self.init(
            value: WeakOrNotReferenceType(target),
            id: ReferenceID(of: target),
            typeName: TypeName(of: target),
            description: "\(target)",
            foundLocations: foundLocations
        )
    }


    public var isReleased: Bool {
        guard let weak = self.value.weak else {
            return true
        }

        return weak.isReleased
    }


    public func found(location: IdentifiableReferencePath) {
        self.foundLocations.append(location)
    }
}



extension Reference: Hashable {
    public var hashValue: Int {
        return self.id.hashValue
    }


    public static func ==(lhs: Reference, rhs: Reference) -> Bool {
        return lhs.id == rhs.id
    }
}
