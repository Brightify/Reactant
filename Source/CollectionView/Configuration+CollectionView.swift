//
//  Configuration+CollectionView.swift
//  Reactant
//
//  Created by Robin Krenecky on 24/04/2018.
//  Copyright © 2018 Brightify. All rights reserved.
//

#if canImport(UIKit)
import UIKit

public final class CollectionViewConfiguration: BaseSubConfiguration {
    public var collectionView: (ReactantCollectionView) -> Void {
        get {
            return configuration.get(valueFor: Properties.Style.CollectionView.collectionView)
        }
        set {
            configuration.set(Properties.Style.CollectionView.collectionView, to: newValue)
        }
    }

    public var reusableViewWrapper: (UICollectionReusableView) -> Void {
        get {
            return configuration.get(valueFor: Properties.Style.CollectionView.reusableViewWrapper)
        }
        set {
            configuration.set(Properties.Style.CollectionView.reusableViewWrapper, to: newValue)
        }
    }

    public var cellWrapper: (UICollectionViewCell) -> Void {
        get {
            return configuration.get(valueFor: Properties.Style.CollectionView.cellWrapper)
        }
        set {
            configuration.set(Properties.Style.CollectionView.cellWrapper, to: newValue)
        }
    }

    public var pageControl: (UIPageControl) -> Void {
        get {
            return configuration.get(valueFor: Properties.Style.CollectionView.pageControl)
        }
        set {
            configuration.set(Properties.Style.CollectionView.pageControl, to: newValue)
        }
    }
}

public extension Configuration.Style {
    var collectionView: CollectionViewConfiguration {
        return CollectionViewConfiguration(configuration: configuration)
    }
}
#endif
