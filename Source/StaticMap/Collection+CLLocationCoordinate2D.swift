//
//  Collection+CLLocationCoordinate2D.swift
//  Reactant
//
//  Created by Filip Dolnik on 26.02.17.
//  Copyright © 2017 Brightify. All rights reserved.
//

import MapKit

internal func degreesToRadians(_ value: Double) -> Double {
    return value * Double.pi / 180.0
}

internal func radiansToDegrees(_ value: Double) -> Double {
    return value * 180.0 / Double.pi
}

extension Collection where Iterator.Element == CLLocationCoordinate2D {
    
    public func centerCoordinate() -> CLLocationCoordinate2D {
        guard count > 1 else { return first ?? CLLocationCoordinate2D() }
        
        let vector = reduce(DoubleVector3()) { accumulator, coordinate in
            let latitude = degreesToRadians(coordinate.latitude)
            let longitude = degreesToRadians(coordinate.longitude)
            let vector = DoubleVector3(
                x: cos(latitude) * cos(longitude),
                y: cos(latitude) * sin(longitude),
                z: sin(latitude))
            return accumulator + vector
            } / Double(count)
        
        let resultLongitude = atan2(vector.y, vector.x)
        let resultSquareRoot = sqrt(vector.x * vector.x + vector.y * vector.y)
        let resultLatitude = atan2(vector.z, resultSquareRoot)
        
        return CLLocationCoordinate2D(
            latitude: radiansToDegrees(resultLatitude),
            longitude: radiansToDegrees(resultLongitude))
    }
    
    public func coordinateSpan() -> MKCoordinateSpan {
        var minLatitude: Double = 90
        var maxLatitude: Double = -90
        var minLongitude: Double = 180
        var maxLongitude: Double = -180
        
        for coordinates in self {
            minLatitude = Swift.min(minLatitude, coordinates.latitude)
            maxLatitude = Swift.max(maxLatitude, coordinates.latitude)
            minLongitude = Swift.min(minLongitude, coordinates.longitude)
            maxLongitude = Swift.max(maxLongitude, coordinates.longitude)
        }
        
        return MKCoordinateSpan(latitudeDelta: maxLatitude - minLatitude, longitudeDelta: maxLongitude - minLongitude)
    }
    
    func boundingCoordinateRegion() -> MKCoordinateRegion {
        return MKCoordinateRegion(center: centerCoordinate(), span: coordinateSpan())
    }
}

fileprivate struct DoubleVector3 {
    var x: Double = 0
    var y: Double = 0
    var z: Double = 0
}

fileprivate func + (lhs: DoubleVector3, rhs: DoubleVector3) -> DoubleVector3 {
    return DoubleVector3(
        x: lhs.x + rhs.x,
        y: lhs.y + rhs.y,
        z: lhs.z + rhs.z)
}

fileprivate func / (lhs: DoubleVector3, rhs: Double) -> DoubleVector3 {
    return DoubleVector3(
        x: lhs.x / rhs,
        y: lhs.y / rhs,
        z: lhs.z / rhs)
}

