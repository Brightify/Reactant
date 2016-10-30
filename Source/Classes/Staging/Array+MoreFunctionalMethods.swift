public extension Array {

    public func arrayByAppending(_ elements: Element...) -> Array<Element> {
        return arrayByAppending(elements)
    }
    
    public func arrayByAppending(_ elements: [Element]) -> Array<Element> {
        var mutableCopy = self
        mutableCopy.append(contentsOf: elements)
        return mutableCopy
    }
    
    public func product<U>(_ other: [U]) -> Array<(Element, U)> {
        return flatMap { t in
            other.map { u in (t, u) }
        }
    }
}
