//
//  BaseSubConfiguration.swift
//  Reactant
//
//  Created by Robin Krenecky on 24/04/2018.
//  Copyright © 2018 Brightify. All rights reserved.
//

open class BaseSubConfiguration: SubConfiguration {
    public let configuration: ReactantConfiguration

    public required init(configuration: ReactantConfiguration) {
        self.configuration = configuration
    }
}
