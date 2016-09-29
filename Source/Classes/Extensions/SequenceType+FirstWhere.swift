//
//  SequenceType+FirstWhere.swift
//
//  Created by Tadeáš Kříž on 15/06/16.
//

public extension Sequence {

    public func first(where condition: (Iterator.Element) -> Bool) -> Iterator.Element? {
        for item in self where condition(item) {
            return item
        }
        return nil
    }

}
