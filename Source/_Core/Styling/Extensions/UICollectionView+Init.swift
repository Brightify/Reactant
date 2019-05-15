//
//  UICollectionView+Init.swift
//  Reactant
//
//  Created by Tadeas Kriz on 31/03/16.
//  Copyright © 2016 Brightify. All rights reserved.
//

#if canImport(UIKit)
import UIKit

extension UICollectionView {
    
    public convenience init(collectionViewLayout layout: UICollectionViewLayout) {
        self.init(frame: CGRect.zero, collectionViewLayout: layout)
    }
}
#endif
