public struct MemoryLeakReport: Hashable {
    public let leakedObjects: Set<LeakedObject>


    public init(leakedObjects: Set<LeakedObject>) {
        self.leakedObjects = leakedObjects
    }


    public init<Seq: Sequence>(references: Seq) where Seq.Element == Reference {
        let leakedObjects = Set(references.compactMap { LeakedObject(reference: $0) })
        self.init(leakedObjects: leakedObjects)
    }
}



extension MemoryLeakReport: PrettyPrintable {
    public var descriptionLines: [IndentedLine] {
        let leakedObjectsPart = sections(self.leakedObjects.map { $0.descriptionLines })

        return sections([
            (name: "Summary", body: lines([
                "Found \(self.leakedObjects.count) leaked objects",
            ])),
            (name: "Leaked objects", body: leakedObjectsPart),
        ])
    }
}
