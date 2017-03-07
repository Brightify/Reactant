//
//  StaticMap.swift
//  Reactant
//
//  Created by Tadeáš Kříž on 09/09/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import MapKit
import RxCocoa
import RxSwift
import Kingfisher

#if os(iOS)
// TODO Move to subspec with Kingfisher.

open class StaticMap: ViewBase<MKCoordinateRegion, Void> {

    open var selected: Observable<Void> {
        return tapGestureRecognizer.rx.event.rewrite(with: Void())
    }

    private let image = ImageView()

    private let tapGestureRecognizer = UIGestureRecognizer()

    public override init() {
        super.init()
    }

    open override func update() {
        layoutIfNeeded()
        image.image = nil
        let fileName = String(format: "map-image-c%.2f,%.2f-s%.2f,%.2f-%.0fx%.0f",
                              componentState.center.latitude, componentState.center.longitude,
                              componentState.span.latitudeDelta, componentState.span.longitudeDelta,
                              bounds.size.width, bounds.size.height)

        ImageCache.default.retrieveImage(forKey: fileName, options: nil) { [image, componentState, bounds] cachedImage, _ in
            if let cachedImage = cachedImage {
                image.image = cachedImage
            } else {
                DispatchQueue.global().async {
                    let options = MKMapSnapshotOptions()
                    options.region = componentState
                    options.scale = UIScreen.main.scale
                    options.size = bounds.size

                    let snapshotter = MKMapSnapshotter(options: options)
                    snapshotter.start { snapshot, error in
                        guard let snapshot = snapshot else { return }
                        let snapshotImage = snapshot.image

                        UIGraphicsBeginImageContextWithOptions(snapshotImage.size, true, snapshotImage.scale)
                        snapshotImage.draw(at: CGPoint.zero)

                        let compositeImage = UIGraphicsGetImageFromCurrentImageContext()
                        UIGraphicsEndImageContext()

                        if let imageToCache = compositeImage {
                            ImageCache.default.store(imageToCache, forKey: fileName)
                        }
                        
                        image.image = compositeImage
                    }
                }
            }
        }
    }

    open override func loadView() {
        children(
            image
        )

        backgroundColor = UIColor.white
        image.contentMode = .scaleAspectFill
        addGestureRecognizer(tapGestureRecognizer)
    }

    open override func setupConstraints() {
        image.setContentHuggingPriority(UILayoutPriorityDefaultLow, for: .horizontal)
        image.setContentHuggingPriority(UILayoutPriorityDefaultLow, for: .vertical)
        image.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
    }
}

import CoreLocation

extension Collection where Iterator.Element == CLLocationCoordinate2D, IndexDistance == Int {

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

private func degreesToRadians(_ value: Double) -> Double {
    return value * M_PI / 180.0
}

private func radiansToDegrees(_ value: Double) -> Double {
    return value * 180.0 / M_PI
}

extension MKCoordinateSpan {
    public func inset(percent: Double) -> MKCoordinateSpan {
        return inset(horizontalPercent: percent, verticalPercent: percent)
    }

    public func inset(horizontalPercent horizontal: Double, verticalPercent vertical: Double) -> MKCoordinateSpan {
        return MKCoordinateSpan(
            latitudeDelta: latitudeDelta + latitudeDelta * vertical,
            longitudeDelta: longitudeDelta + longitudeDelta * horizontal)
    }
}
#endif
