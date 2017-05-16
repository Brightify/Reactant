//
//  FlowCollectionViewBase.swift
//  Reactant
//
//  Created by Filip Dolnik on 13.02.17.
//  Copyright © 2017 Brightify. All rights reserved.
//

#if os(iOS)
import UIKit

open class FlowCollectionViewBase<MODEL, ACTION>: CollectionViewBase<MODEL, ACTION> {
    
    public let collectionViewLayout = UICollectionViewFlowLayout()
    
    public init(reloadable: Bool = true) {
        super.init(layout: collectionViewLayout, reloadable: reloadable)
    }
}
#endif
