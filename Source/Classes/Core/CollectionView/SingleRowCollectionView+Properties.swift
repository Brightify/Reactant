//
//  SingleRowCollectionView+Properties.swift
//  Reactant
//
//  Created by Filip Dolnik on 21.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import UIKit

extension SingleRowCollectionView {
    
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
    
    public var contentInset: UIEdgeInsets {
        get {
            return collectionView.contentInset
        }
        set {
            collectionView.contentInset = newValue
        }
    }
}
