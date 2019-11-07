//
//  ComponentBase+spy.swift
//  ReactantTests
//
//  Created by Tadeas Kriz on 07/11/2019.
//  Copyright © 2019 Brightify. All rights reserved.
//

import Reactant
import Cuckoo

extension ComponentBase {
    static func spy(canUpdate: Bool = true) -> MockComponentBase<STATE, ACTION> {
        return createMock(MockComponentBase.self) { builder, stub in
            builder.enableSuperclassSpy()
            return MockComponentBase<STATE, ACTION>(canUpdate: canUpdate)
        }
    }
}

