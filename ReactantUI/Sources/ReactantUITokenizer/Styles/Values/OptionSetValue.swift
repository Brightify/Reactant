protocol OptionSetValue {
    associatedtype Value: OptionSet

    var value: Value { get }
}



extension Sequence where Iterator.Element: OptionSetValue {
    func resolveUnion() -> Iterator.Element.Value {
        return reduce([] as Iterator.Element.Value) {
            $0.union($1.value)
        }
    }
}
