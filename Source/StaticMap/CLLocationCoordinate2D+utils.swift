//
//  CLLocationCoordinate2D+utils.swift
//  Reactant
//
//  Created by Filip Dolnik on 26.02.17.
//  Copyright © 2017 Brightify. All rights reserved.
//

import MapKit

extension CLLocationCoordinate2D {
    
    public static func startAndEnd(region: MKCoordinateRegion) -> (start: CLLocationCoordinate2D, end: CLLocationCoordinate2D) {
        let center = region.center
        let centerLat = center.latitude
        let centerLon = center.longitude
        let span = region.span
        let latDelta = span.latitudeDelta
        let lonDelta = span.longitudeDelta
        let start = CLLocationCoordinate2D(latitude: centerLat - (latDelta / 2), longitude: centerLon - (lonDelta / 2))
        let end = CLLocationCoordinate2D(latitude: centerLat + (latDelta / 2), longitude: centerLon + (lonDelta / 2))
        
        return (start, end)
    }
}

extension CLLocationCoordinate2D: Hashable {
    
    public var hashValue: Int {
        return [latitude.hashValue, longitude.hashValue].djbHash()
    }
}

public func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
    return lhs.latitude.equal(to: rhs.latitude) && lhs.longitude.equal(to: rhs.longitude)
}

private extension Double {
    func equal(to value: Double, precision: Double = Double.ulpOfOne) -> Bool {
        return abs(self - value) <= precision
    }
}
