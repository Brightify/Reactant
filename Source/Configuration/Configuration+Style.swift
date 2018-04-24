//
//  Configuration+Style.swift
//  Reactant
//
//  Created by Robin Krenecky on 24/04/2018.
//  Copyright © 2018 Brightify. All rights reserved.
//

public final class StyleConfiguration: BaseSubConfiguration {
}

extension Configuration {
    public var style: StyleConfiguration {
        return StyleConfiguration(configuration: self)
    }
}
