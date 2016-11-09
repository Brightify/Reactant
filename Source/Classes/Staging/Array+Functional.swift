public extension Array {

    public func arrayByAppending(_ elements: Element...) -> Array<Element> {
        return arrayByAppending(elements)
    }
    
    public func arrayByAppending(_ elements: [Element]) -> Array<Element> {
        var mutableCopy = self
        mutableCopy.append(contentsOf: elements)
        return mutableCopy
    }
}
