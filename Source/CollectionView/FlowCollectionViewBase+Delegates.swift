//
//  FlowCollectionViewBase+Delegates.swift
//  Reactant
//
//  Created by Filip Dolnik on 13.02.17.
//  Copyright © 2017 Brightify. All rights reserved.
//

#if os(iOS)
import UIKit

extension FlowCollectionViewBase {
    
    public var estimatedItemSize: CGSize {
        get {
            return collectionViewLayout.estimatedItemSize
        }
        set {
            collectionViewLayout.estimatedItemSize = newValue
        }
    }
    
    public var itemSize: CGSize {
        get {
            return collectionViewLayout.itemSize
        }
        set {
            collectionViewLayout.itemSize = newValue
        }
    }
    
    public var minimumLineSpacing: CGFloat {
        get {
            return collectionViewLayout.minimumLineSpacing
        }
        set {
            collectionViewLayout.minimumLineSpacing = newValue
        }
    }
    
    public var scrollDirection: UICollectionViewScrollDirection {
        get {
            return collectionViewLayout.scrollDirection
        }
        set {
            collectionViewLayout.scrollDirection = newValue
        }
    }
}
#endif
