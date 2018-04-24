//
//  SubConfiguration.swift
//  Reactant
//
//  Created by Robin Krenecky on 24/04/2018.
//  Copyright © 2018 Brightify. All rights reserved.
//

public protocol SubConfiguration {
    var configuration: Configuration { get }

    init(configuration: Configuration)
}
