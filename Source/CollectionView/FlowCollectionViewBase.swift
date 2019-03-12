//
//  FlowCollectionViewBase.swift
//  Reactant
//
//  Created by Filip Dolnik on 13.02.17.
//  Copyright © 2017 Brightify. All rights reserved.
//

#if canImport(UIKit)
import UIKit

open class FlowCollectionViewBase<MODEL, ACTION>: CollectionViewBase<MODEL, ACTION> {
    
    public let collectionViewLayout = UICollectionViewFlowLayout()

    /// - parameter reloadable: determines whether the **FlowCollectionViewBase** should be reloadable by pulling
    public init(reloadable: Bool = true, automaticallyDeselect: Bool = true) {
        super.init(layout: collectionViewLayout, reloadable: reloadable, automaticallyDeselect: automaticallyDeselect)
    }
}
#endif
