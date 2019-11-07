//
//  StaticMap.swift
//  Reactant
//
//  Created by Tadeáš Kříž on 09/09/16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import MapKit
import RxCocoa
import RxSwift
import Kingfisher

public enum StaticMapAction {
    case selected
}

open class StaticMap: ViewBase<MKCoordinateRegion, StaticMapAction> {

    open override var actions: [Observable<StaticMapAction>] {
        return [tapGestureRecognizer.rx.event.rewrite(with: StaticMapAction.selected)]
    }

    private let image = UIImageView()
    private let tapGestureRecognizer = UITapGestureRecognizer()

    public override init() {
        super.init()

        componentDelegate.canUpdate = false
    }

    open override func loadView() {
        children(
            image
        )

        backgroundColor = .white
        image.contentMode = .scaleAspectFill
        addGestureRecognizer(tapGestureRecognizer)
    }

    open override func setupConstraints() {
        image.setContentHuggingPriority(UILayoutPriority.defaultLow, for: .horizontal)
        image.setContentHuggingPriority(UILayoutPriority.defaultLow, for: .vertical)
        image.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
    }

    open override func layoutSubviews() {
        super.layoutSubviews()

        if bounds.size != .zero {
            componentDelegate.canUpdate = true
        }
    }

    open override func update() {
        image.image = nil
        let fileName = String(format: "map-image-c%.2f,%.2f-s%.2f,%.2f-%.0fx%.0f",
                              componentState.center.latitude, componentState.center.longitude,
                              componentState.span.latitudeDelta, componentState.span.longitudeDelta,
                              bounds.size.width, bounds.size.height)

        ImageCache.default.retrieveImage(forKey: fileName, options: nil) { [image, componentState, bounds] result in
            if let cachedImage = result.value?.image {
                image.image = cachedImage
            } else {
                DispatchQueue.global().async {
                    let options = MKMapSnapshotter.Options()
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
}
