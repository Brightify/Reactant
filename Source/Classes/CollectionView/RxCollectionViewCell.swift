//
//  RxCollectionViewCell.swift
//
//  Created by Maros Seleng on 10/05/16.
//
import SwiftKit

open protocol CollectionViewCellContent {
    func setSelected(_ selected: Bool)

    func setHighlighted(_ highlighted: Bool)
}

extension CollectionViewCellContent {
    open func setSelected(_ selected: Bool) { }

    open func setHighlighted(_ highlighted: Bool) { }
}

open final class RxCollectionViewCell<CONTENT: UIView>: UICollectionViewCell {
    private var content: CONTENT?

    open override class var requiresConstraintBasedLayout: Bool {
        return true
    }

    open override var isSelected: Bool {
        didSet {
            if let content = content as? CollectionViewCellContent {
                content.setSelected(isSelected)
            }
        }
    }

    open override var isHighlighted: Bool {
        didSet {
            if let content = content as? CollectionViewCellContent {
                content.setHighlighted(isHighlighted)
            }
        }
    }

    open func cachedContentOrCreated(factory: () -> CONTENT) -> CONTENT {
        if let content = content {
            return content
        } else {
            let content = factory()
            self.content = content
            contentView.children(content)
            setNeedsUpdateConstraints()
            return content
        }
    }
    
    open override func updateConstraints() {
        super.updateConstraints()
        
        content?.snp.updateConstraints { make in
            make.edges.equalTo(contentView)
        }
    }
}
