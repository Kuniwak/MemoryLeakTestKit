public enum ReferenceID {
    case anyReferenceType(name: TypeName, objectIdentifier: ObjectIdentifier)
    case anyValueType(name: TypeName)
    case unknown(name: TypeName)


    public init<T>(of target: T) {
        switch Mirror(reflecting: target).displayStyle {
        case .some(.class):
            let objectIdentifier = ObjectIdentifier(target as AnyObject)
            self = .anyReferenceType(
                name: TypeName(of: target),
                objectIdentifier: objectIdentifier
            )

        case .some(.tuple), .some(.struct), .some(.collection), .some(.dictionary),
             .some(.enum), .some(.optional), .some(.set):
            self = .anyValueType(name: TypeName(of: target))

        case .none:
            self = .unknown(name: TypeName(of: target))
        }
    }
}



extension ReferenceID: Equatable {
    public static func ==(lhs: ReferenceID, rhs: ReferenceID) -> Bool {
        switch (lhs, rhs) {
        case (.anyReferenceType(name: _, objectIdentifier: let l), .anyReferenceType(name: _, objectIdentifier: let r)):
            return l == r

        default:
            // NOTE: Any values should not be identical.
            return false
        }
    }
}



extension ReferenceID: Hashable {
    public var hashValue: Int {
        switch self {
        case .anyReferenceType(name: _, objectIdentifier: let objectIdentifier):
            return objectIdentifier.hashValue

        case .anyValueType:
            // NOTE: Any values should not be identical.
            return 0

        case .unknown:
            return 1
        }
    }
}
