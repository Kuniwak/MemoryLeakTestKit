public struct LeakedObject: Hashable {
    public let objectDescription: String
    public let typeName: TypeName
    public let location: ReferencePath
    public let circularPaths: Set<CircularReferencePath>


    public init(
        objectDescription: String,
        typeName: TypeName,
        location: ReferencePath,
        circularPaths: Set<CircularReferencePath>
    ) {
        self.objectDescription = objectDescription
        self.typeName = typeName
        self.location = location
        self.circularPaths = circularPaths
    }


    public init?(reference: Reference) {
        guard !reference.isReleased else {
            return nil
        }

        self.init(
            objectDescription: reference.destinationObjectDescription,
            typeName: reference.destinationTypeName,
            location: ReferencePath(identifiablePath: reference.foundLocations.first),
            circularPaths: Set(reference.foundLocations.flatMap { identifiablePath in
                return CircularReferencePath.from(
                    rootTypeName: reference.destinationTypeName,
                    identifiablePath: identifiablePath
                )
            })
        )
    }
}



extension LeakedObject: PrettyPrintable {
    public var descriptionLines: [IndentedLine] {
        return descriptionList([
            (label: "Description", description: self.objectDescription),
            (label: "Type", description: self.typeName.text),
            (label: "Location", description: self.location.description),
            (label: "Circular Paths", description: "")
        ]) + indent(lines(self.circularPaths.map { $0.description }))
    }
}
