public class Weak<T: AnyObject> {
    public private(set) weak var value: T?


    public init(_ value: T) {
        self.value = value
    }


    public init() {
        self.value = nil
    }


    public var isReleased: Bool {
        return self.value == nil
    }
}
