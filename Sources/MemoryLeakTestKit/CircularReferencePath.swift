public struct CircularReferencePath: Hashable {
    public let end: CircularPathEnd
    public let components: ArrayLongerThan1<ReferencePathComponent>


    public var description: String {
        let accessors = self.components
            .map { $0.description }
            .joined(separator: "")

        return "self\(accessors) === self"
    }


    public init(end: CircularPathEnd, components: ArrayLongerThan1<ReferencePathComponent>) {
        self.end = end
        self.components = components
    }


    public static func from(rootTypeName: TypeName, identifiablePath: IdentifiableReferencePath) -> Set<CircularReferencePath> {
        guard let idComponents = ArrayLongerThan1<IdentifiableReferencePathComponent>(identifiablePath.idComponents) else {
            return []
        }

        let lastIdComponent = idComponents.last

        var result = Set<CircularReferencePath>()
        let idComponentsCount = idComponents.count

        if lastIdComponent.isIdentified(by: identifiablePath.rootID) {
            result.insert(CircularReferencePath(
                end: .root(rootTypeName),
                components: ReferencePathNormalization.normalize(idComponents.map { $0.noNormalizedComponent })
            ))
        }

        result.formUnion(
            Set(idComponents
                .enumerated()
                .filter { indexAndIdComponent in
                    let (_, idComponent) = indexAndIdComponent
                    return idComponent == lastIdComponent
                }
                .compactMap { indexAndIdComponent -> ArrayLongerThan1<IdentifiableReferencePathComponent>? in
                    let (circularStartIndex, _) = indexAndIdComponent
                    let circularNextIndex = circularStartIndex + 1
                    let circularIdComponents = idComponents[circularNextIndex..<idComponentsCount]
                    return ArrayLongerThan1<IdentifiableReferencePathComponent>(circularIdComponents)
                }
                .map { circularComponents -> CircularReferencePath in
                    return CircularReferencePath(
                        end: .intermediate(lastIdComponent.typeName),
                        components: ReferencePathNormalization.normalize(circularComponents.map { $0.noNormalizedComponent })
                    )
                }
            )
        )

        return result
    }
}



public enum CircularPathEnd: Hashable {
    case root(TypeName)
    case intermediate(TypeName)
}
