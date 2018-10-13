public enum NotNormalizedReferencePathComponent: Hashable {
    case label(String)
    case index(Int)
    case noLabel


    public init(
        isCollection: Bool,
        index: Int,
        label: String?
    ) {
        guard !isCollection else {
            self = .index(index)
            return
        }

        guard let label = label else {
            self = .noLabel
            return
        }

        self = .label(label)
    }
}
