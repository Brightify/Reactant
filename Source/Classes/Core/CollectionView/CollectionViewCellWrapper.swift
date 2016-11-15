//
//  CollectionViewCellWrapper.swift
//  Reactant
//
//  Created by Filip Dolnik on 14.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import UIKit

public final class CollectionViewCellWrapper<CELL: UIView>: UICollectionViewCell {
    
    private var cell: CELL?
    
    public override class var requiresConstraintBasedLayout: Bool {
        return true
    }
    
    private var collectionViewCell: CollectionViewCell? {
        return cell as? CollectionViewCell
    }
    
    public override var isSelected: Bool {
        didSet {
            collectionViewCell?.setSelected(isSelected)
        }
    }
    
    public override var isHighlighted: Bool {
        didSet {
            collectionViewCell?.setHighlighted(isHighlighted)
        }
    }
    
    public override func updateConstraints() {
        super.updateConstraints()
        
        cell?.snp.updateConstraints { make in
            make.edges.equalTo(contentView)
        }
    }
    
    public func cachedCellOrCreated(factory: () -> CELL) -> CELL {
        if let cell = cell {
            return cell
        } else {
            let cell = factory()
            self.cell = cell
            contentView.children(cell)
            setNeedsUpdateConstraints()
            return cell
        }
    }
    
    public func deleteCachedCell() -> CELL? {
        let cell = self.cell
        cell?.removeFromSuperview()
        self.cell = nil
        return cell
    }
}
