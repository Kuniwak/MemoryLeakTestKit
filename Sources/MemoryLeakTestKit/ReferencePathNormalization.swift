// NOTE: Mirror.Child for values stored on lazy var become the following unreadable value:
//       (label: propertyName + ".storage", value: Optional.some(value))
public enum ReferencePathNormalization {
    public static let lazyStorageLabelSuffix = ".storage"
    public static let optionalSomeLabel = "some"


    public static func normalize(
        _ noNormalizedComponents: [NotNormalizedReferencePathComponent]
    ) -> [ReferencePathComponent] {
        return self.normalize(hints: noNormalizedComponents.map { Hint($0) })
    }


    public static func normalize(
        _ noNormalizedComponents: ArrayLongerThan1<NotNormalizedReferencePathComponent>
    ) -> ArrayLongerThan1<ReferencePathComponent> {
        return self.normalize(hints: noNormalizedComponents.map { Hint($0) })
    }


    public static func normalize(
        _ noNormalizedComponents: ArrayLongerThan2<NotNormalizedReferencePathComponent>
    ) -> ArrayLongerThan1<ReferencePathComponent> {
        return self.normalize(hints: noNormalizedComponents.map { Hint($0) })
    }


    public static func normalize(
        hints: [Hint]
    ) -> [ReferencePathComponent] {
        guard let noEmptyHints = ArrayLongerThan1<Hint>(hints) else {
            return []
        }

        return Array(self.normalize(hints: noEmptyHints).sequence())
    }


    public static func normalize(
        hints: ArrayLongerThan1<Hint>
    ) -> ArrayLongerThan1<ReferencePathComponent> {
        guard let noEmptyHints = ArrayLongerThan2<Hint>(hints) else {
            return ArrayLongerThan1(prefix: self.normalize(initialHint: hints.first, nextHintIfExists: nil), [])
        }

        return self.normalize(hints: noEmptyHints)
    }


    public static func normalize(
        hints: ArrayLongerThan2<Hint>
    ) -> ArrayLongerThan1<ReferencePathComponent> {
        let prefix = self.contextDependedNormalize(currentHint: hints.prefix, nextHintIfExists: hints.rest.prefix)
        var suffixed = hints.map(Optional<Hint>.some)
        suffixed.append(nil)

        // NOTE: Create a pair that represent a bidirectional contexts.
        //       (prev, current, nextIfExists)
        //       [0, 1] -> [(0, 1, nil)]
        //       [0, 1, 2] -> [(0, 1, 2), (1, 2, nil)]
        let intermediates = zip(hints.relaxed().relaxed(), hints.dropFirst().relaxed(), suffixed.dropFirst().dropFirst())
            .compactMap { slided -> ReferencePathComponent? in
                let (previousHint, currentHint, nextHintIfExists) = slided
                return self.normalize(
                    previousHint: previousHint,
                    currentHint: currentHint,
                    nextHintIfExists: nextHintIfExists
                )
            }

        return .init(prefix: prefix, intermediates)
    }


    public static func normalize(initialHint: Hint, nextHintIfExists: Hint?) -> ReferencePathComponent {
        return self.contextDependedNormalize(currentHint: initialHint, nextHintIfExists: nextHintIfExists)
    }


    public static func normalize(previousHint: Hint, currentHint: Hint, nextHintIfExists: Hint?) -> ReferencePathComponent? {
        switch (previousHint, currentHint, nextHintIfExists) {
        case (.hasLazyStorageSuffix, .isOptionalSome, _):
            return nil
        default:
            return self.contextDependedNormalize(currentHint: currentHint, nextHintIfExists: nextHintIfExists)
        }
    }


    // NOTE: This method can work properly only if the previous hint is not a lazy storage suffix.
    public static func contextDependedNormalize(currentHint: Hint, nextHintIfExists: Hint?) -> ReferencePathComponent {
        switch (currentHint, nextHintIfExists) {
        case (.hasLazyStorageSuffix(label: let label), .some(.isOptionalSome)):
            return .label(String(label.dropLast(self.lazyStorageLabelSuffix.count)))
        case (.hasLazyStorageSuffix(label: let label), _), (.none(.label(let label)), _):
            return .label(label)
        case (.none(.index(let index)), _):
            return .index(index)
        case (.none(.noLabel), _):
            return .noLabel
        case (.isOptionalSome, _):
            return .label(self.optionalSomeLabel)
        }
    }



    public enum Hint: Equatable {
        case none(NotNormalizedReferencePathComponent)
        case hasLazyStorageSuffix(label: String)
        case isOptionalSome


        public init(_ component: NotNormalizedReferencePathComponent) {
            switch component {
            case .label(let label):
                if label.hasSuffix(ReferencePathNormalization.lazyStorageLabelSuffix) {
                    self = .hasLazyStorageSuffix(label: label)
                }
                else if (label == ReferencePathNormalization.optionalSomeLabel) {
                    self = .isOptionalSome
                }
                else {
                    self = .none(component)
                }
            case .noLabel, .index:
                self = .none(component)
            }
        }
    }
}
