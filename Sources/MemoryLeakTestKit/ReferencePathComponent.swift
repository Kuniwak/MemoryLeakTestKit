public enum ReferencePathComponent: Hashable {
    case label(String)
    case index(Int)
    case noLabel


    public var description: String {
        switch self {
        case .label(let label):
            return ".\(label)"
        case .index(let index):
            return "[\(index)]"
        case .noLabel:
            return "[unknown accessor]"
        }
    }
}
