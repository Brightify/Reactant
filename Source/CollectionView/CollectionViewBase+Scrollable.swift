//
//  CollectionViewBase+Scrollable.swift
//  Reactant
//
//  Created by Filip Dolnik on 13.02.17.
//  Copyright © 2017 Brightify. All rights reserved.
//

extension CollectionViewBase: Scrollable {
    
    public func scrollToTop(animated: Bool) {
        collectionView.scrollToTop(animated: animated)
    }
}
