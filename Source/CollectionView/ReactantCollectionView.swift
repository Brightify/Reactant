//
//  ReactantCollectionView.swift
//  Reactant
//
//  Created by Filip Dolnik on 16.02.17.
//  Copyright © 2017 Brightify. All rights reserved.
//

#if canImport(UIKit)
import UIKit

public protocol ReactantCollectionView: class, Scrollable {
    
    var collectionView: UICollectionView { get }
    #if os(iOS)
    var refreshControl: UIRefreshControl? { get }
    #endif
    var emptyLabel: UILabel  { get }
    var loadingIndicator: UIActivityIndicatorView { get }
}

extension ReactantCollectionView {

    /**
     * Scroll the Reactant Collection View to top.
     * - parameter animated: determines whether the scroll to top is animated
     */
    public func scrollToTop(animated: Bool) {
        collectionView.scrollToTop(animated: animated)
    }
}
#endif
