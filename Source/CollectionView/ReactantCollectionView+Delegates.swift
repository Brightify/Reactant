//
//  ReactantCollectionView+Delegates.swift
//  Reactant
//
//  Created by Filip Dolnik on 13.02.17.
//  Copyright © 2017 Brightify. All rights reserved.
//

#if canImport(UIKit)
import UIKit

extension ReactantCollectionView {

    #if os(iOS)
    /**
     * The tint color for the refresh control.
     * The default value of this property is nil.
     */
    public var refreshControlTintColor: UIColor? {
        get {
            return refreshControl?.tintColor
        }
        set {
            refreshControl?.tintColor = newValue
        }
    }
    #endif

    /**
     * The basic appearance of the activity indicator.
     * See **UIActivityIndicatorViewStyle** for the available styles. The default value is white.
     */
    public var activityIndicatorStyle: UIActivityIndicatorView.Style {
        get {
            return loadingIndicator.style
        }
        set {
            loadingIndicator.style = newValue
        }
    }

    /**
     * The distance that the content view is inset from the enclosing scroll view.
     * Use this property to add to the scrolling area around the content. The unit of size is points. The default value is `UIEdgeInsetsZero`.
     */
    public var contentInset: UIEdgeInsets {
        get {
            return collectionView.contentInset
        }
        set {
            collectionView.contentInset = newValue
        }
    }
}
#endif
