//
//  SequenceType+Transform.swift
//
//  Created by Tadeáš Kříž on 17/04/16.
//

public extension SequenceType {
    public func transform(transformation: (inout Generator.Element) -> Void) -> [Generator.Element] {
        return map {
            var mutableItem = $0
            transformation(&mutableItem)
            return mutableItem
        }
    }
}
