//
//  MKCoordinateSpan+inset.swift
//  Reactant
//
//  Created by Filip Dolnik on 26.02.17.
//  Copyright © 2017 Brightify. All rights reserved.
//

import MapKit

extension MKCoordinateSpan {
    
    public func inset(percent: Double) -> MKCoordinateSpan {
        return inset(horizontalPercent: percent, verticalPercent: percent)
    }
    
    public func inset(horizontalPercent horizontal: Double, verticalPercent vertical: Double) -> MKCoordinateSpan {
        return MKCoordinateSpan(
            latitudeDelta: latitudeDelta * (1 + vertical),
            longitudeDelta: longitudeDelta * (1 + horizontal)
        )
    }
}
