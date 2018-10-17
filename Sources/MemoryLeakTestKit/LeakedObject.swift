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
        let circularPathsDescription: [IndentedLine]

        if self.circularPaths.isEmpty {
            circularPathsDescription = lines(["No circular references found. There are 2 possible reasons:"])
                + indent(lines([
                    "1. Some outer instances own it",
                    "2. Anonymous instances that are on circular references end own it",
                ]))
        }
        else {
            circularPathsDescription = indent(lines(self.circularPaths.map { $0.description }))
        }

        return descriptionList([
            (label: "Description", description: self.objectDescription),
            (label: "Type", description: self.typeName.text),
            (label: "Location", description: self.location.description),
            (label: "Circular Paths", description: "")
        ]) + circularPathsDescription
    }
}
