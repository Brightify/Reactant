//
//  RxCollectionViewCell.swift
//
//  Created by Maros Seleng on 10/05/16.
//

import UIKit

public protocol CollectionViewCellContent {
    func setSelected(_ selected: Bool)

    func setHighlighted(_ highlighted: Bool)
}

extension CollectionViewCellContent {
    public func setSelected(_ selected: Bool) { }

    public func setHighlighted(_ highlighted: Bool) { }
}

public final class RxCollectionViewCell<CONTENT: UIView>: UICollectionViewCell {
    private var content: CONTENT?

    public override class var requiresConstraintBasedLayout: Bool {
        return true
    }

    public override var isSelected: Bool {
        didSet {
            if let content = content as? CollectionViewCellContent {
                content.setSelected(isSelected)
            }
        }
    }

    public override var isHighlighted: Bool {
        didSet {
            if let content = content as? CollectionViewCellContent {
                content.setHighlighted(isHighlighted)
            }
        }
    }

    public func cachedContentOrCreated(factory: () -> CONTENT) -> CONTENT {
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
    
    public override func updateConstraints() {
        super.updateConstraints()
        
        content?.snp.updateConstraints { make in
            make.edges.equalTo(contentView)
        }
    }
}
