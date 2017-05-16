//
//  ReactantCollectionView+Delegates.swift
//  Reactant
//
//  Created by Filip Dolnik on 13.02.17.
//  Copyright © 2017 Brightify. All rights reserved.
//

#if os(iOS)
import UIKit

extension ReactantCollectionView {
    
    public var refreshControlTintColor: UIColor? {
        get {
            return refreshControl?.tintColor
        }
        set {
            refreshControl?.tintColor = newValue
        }
    }
    
    public var activityIndicatorStyle: UIActivityIndicatorViewStyle {
        get {
            return loadingIndicator.activityIndicatorViewStyle
        }
        set {
            loadingIndicator.activityIndicatorViewStyle = newValue
        }
    }
    
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
