//
//  Configuration+LoadableView.swift
//  Reactant
//
//  Created by Robin Krenecky on 24/04/2018.
//  Copyright © 2018 Brightify. All rights reserved.
//

import SkeletonView

private let showLoadingProperty = Property<(UIView) -> Void>(defaultValue: { $0.showAnimatedGradientSkeleton() })

public final class LoadableViewConfiguration: BaseSubConfiguration {
    public var showLoading: (UIView) -> Void {
        get {
            return configuration.get(valueFor: showLoadingProperty)
        }
        set {
            configuration.set(showLoadingProperty, to: newValue)
        }
    }
}

public extension Configuration.Style {
    var loadableView: LoadableViewConfiguration {
        return LoadableViewConfiguration(configuration: configuration)
    }
}
