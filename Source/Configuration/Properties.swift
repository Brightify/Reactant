//
//  Properties.swift
//  Reactant
//
//  Created by Filip Dolnik on 14.02.17.
//  Copyright © 2017 Brightify. All rights reserved.
//

/// A structure containing all available properties. These are added through extensions.
public struct Properties {
    
    // Has to be declared here because of https://bugs.swift.org/browse/SR-631 . (Move to Properties+Style when resolved.)
    /**
     * A structure for style properties. The main difference is that style properties are clusures with one parameter
     * which is the styled view.
     */
    public struct Style {
        private init() { }
    }
    
    private init() { }
}
