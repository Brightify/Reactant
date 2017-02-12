//
//  SingleRowCollectionView.swift
//  Reactant
//
//  Created by Filip Dolnik on 12.02.17.
//  Copyright © 2017 Brightify. All rights reserved.
//

import UIKit

open class SingleRowCollectionView<CELL: UIView>: PlainCollectionView<CELL> where CELL: Component {
    
    open override func loadView() {
        super.loadView()
        
        collectionViewLayout.itemSize = CGSize.zero
        collectionViewLayout.minimumLineSpacing = 0
        collectionViewLayout.scrollDirection = .horizontal
    }
}
