//
//  BehaviorRelay+mutate.swift
//  Reactant
//
//  Created by Matyáš Kříž on 13/07/2018.
//  Copyright © 2018 Brightify. All rights reserved.
//

import RxCocoa

extension BehaviorRelay {
    internal func mutate(using mutator: (inout Element) -> Void) {
        var mutableValue = value
        mutator(&mutableValue)
        accept(mutableValue)
    }
}
