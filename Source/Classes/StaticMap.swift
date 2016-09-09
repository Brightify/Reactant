//
//  StaticMap.swift
//  Reactant
//
//  Created by Tadeáš Kříž on 09/09/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import MapKit
import Lipstick
import RxCocoa
import RxSwift
import Haneke

public class StaticMap: ViewBase<MKCoordinateRegion> {

    public var selected: Observable<Void> {
        return tapGestureRecognizer.rx_event.rewrite(Void())
    }

    private let image = UIImageView()

    private let tapGestureRecognizer = UITapGestureRecognizer()

    public override init() {
        super.init()
    }

    public override func render() {
        layoutIfNeeded()
        image.image = nil
        let fileName = String(format: "map-image-c%.2f,%.2f-s%.2f,%.2f-%.0fx%.0f",
                              componentState.center.latitude, componentState.center.longitude,
                              componentState.span.latitudeDelta, componentState.span.longitudeDelta,
                              bounds.size.width, bounds.size.height)

        Shared.imageCache.fetch(key: fileName)
            .onSuccess { [image] in image.image = $0 }
            .onFailure { [componentState, bounds, image] _ in
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                    let options = MKMapSnapshotOptions()
                    options.region = componentState
                    options.scale = UIScreen.mainScreen().scale
                    options.size = bounds.size

                    let snapshotter = MKMapSnapshotter(options: options)
                    snapshotter.startWithCompletionHandler { snapshot, error in
                        guard let snapshot = snapshot else { return }
                        let snapshotImage = snapshot.image

                        UIGraphicsBeginImageContextWithOptions(snapshotImage.size, true, snapshotImage.scale)
                        snapshotImage.drawAtPoint(CGPoint.zero)

                        let compositeImage = UIGraphicsGetImageFromCurrentImageContext()
                        UIGraphicsEndImageContext()

                        Shared.imageCache.set(value: compositeImage, key: fileName)

                        image.image = compositeImage
                    }
                }
        }
    }

    public override func loadView() {
        children(
            image
        )

        backgroundColor = white
        image.contentMode = .ScaleAspectFill
        addGestureRecognizer(tapGestureRecognizer)
    }

    public override func setupConstraints() {
        image.setContentHuggingPriority(UILayoutPriorityDefaultLow, forAxis: .Horizontal)
        image.setContentHuggingPriority(UILayoutPriorityDefaultLow, forAxis: .Vertical)
        image.snp_makeConstraints { make in
            make.edges.equalTo(self)
        }
    }
}

import CoreLocation

extension CollectionType where Generator.Element == CLLocationCoordinate2D, Index.Distance == Int {

    /// Calculates center between coordinates in this collection
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
            if coordinates.latitude < minLatitude {
                minLatitude = coordinates.latitude
            }
            if coordinates.longitude < minLongitude {
                minLongitude = coordinates.longitude
            }
            if coordinates.latitude > maxLatitude {
                maxLatitude = coordinates.latitude
            }
            if coordinates.longitude > maxLongitude {
                maxLongitude = coordinates.longitude
            }
        }

        return MKCoordinateSpan(latitudeDelta: maxLatitude - minLatitude, longitudeDelta: maxLongitude - minLongitude)
    }
}

private struct DoubleVector3 {
    var x: Double = 0
    var y: Double = 0
    var z: Double = 0
}

private func + (lhs: DoubleVector3, rhs: DoubleVector3) -> DoubleVector3 {
    return DoubleVector3(
        x: lhs.x + rhs.x,
        y: lhs.y + rhs.y,
        z: lhs.z + rhs.z)
}

private func / (lhs: DoubleVector3, rhs: Double) -> DoubleVector3 {
    return DoubleVector3(
        x: lhs.x / rhs,
        y: lhs.y / rhs,
        z: lhs.z / rhs)
}

private func degreesToRadians(value: Double) -> Double {
    return value * M_PI / 180.0
}

private func radiansToDegrees(value: Double) -> Double {
    return value * 180.0 / M_PI
}

extension MKCoordinateSpan {
    public func inset(percent percent: Double) -> MKCoordinateSpan {
        return inset(horizontalPercent: percent, verticalPercent: percent)
    }

    public func inset(horizontalPercent horizontal: Double, verticalPercent vertical: Double) -> MKCoordinateSpan {
        return MKCoordinateSpan(
            latitudeDelta: latitudeDelta + latitudeDelta * vertical,
            longitudeDelta: longitudeDelta + longitudeDelta * horizontal)
    }
}
