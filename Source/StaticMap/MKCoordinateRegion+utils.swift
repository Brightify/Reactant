//
//  MKCoordinateRegion+utils.swift
//  Reactant
//
//  Created by Filip Dolnik on 26.02.17.
//  Copyright © 2017 Brightify. All rights reserved.
//

import MapKit

extension MKCoordinateRegion {
    
    public func inset(percent: Double) -> MKCoordinateRegion {
        return inset(horizontalPercent: percent, verticalPercent: percent)
    }
    
    public func inset(horizontalPercent horizontal: Double, verticalPercent vertical: Double) -> MKCoordinateRegion {
        return MKCoordinateRegion(
            center: center,
            span: span.inset(horizontalPercent: horizontal, verticalPercent: vertical))
    }
}
