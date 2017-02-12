//
//  ReactantCollectionView.swift
//  Reactant
//
//  Created by Filip Dolnik on 21.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import UIKit

public protocol ReactantCollectionView: class, Scrollable {
    
    associatedtype CollectionViewLayout: UICollectionViewLayout
    
    var collectionView: UICollectionView { get }
    
    var collectionViewLayout: CollectionViewLayout { get }
    
    var refreshControl: UIRefreshControl? { get }
    
    var loadingIndicator: UIActivityIndicatorView { get }
}

extension ReactantCollectionView {
    
    public func scrollToTop(animated: Bool) {
        collectionView.scrollToTop(animated: animated)
    }
}

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

//public var estimatedItemSize: CGSize {
//get {
//    return collectionViewLayout.estimatedItemSize
//}
//set {
//    collectionViewLayout.estimatedItemSize = newValue
//}
//}
//
//public var itemSize: CGSize {
//get {
//    return collectionViewLayout.itemSize
//}
//set {
//    collectionViewLayout.itemSize = newValue
//}
//}
//
//public var minimumLineSpacing: CGFloat {
//get {
//    return collectionViewLayout.minimumLineSpacing
//}
//set {
//    collectionViewLayout.minimumLineSpacing = newValue
//}
//}
//
//public var scrollDirection: UICollectionViewScrollDirection {
//get {
//    return collectionViewLayout.scrollDirection
//}
//set {
//    collectionViewLayout.scrollDirection = newValue
//}
//}
    
