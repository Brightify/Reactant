//
//  RxCollectionViewCell.swift
//
//  Created by Maros Seleng on 10/05/16.
//
import SwiftKit

public protocol CollectionViewCellContent {
    func setSelected(selected: Bool)

    func setHighlighted(highlighted: Bool)
}

extension CollectionViewCellContent {
    public func setSelected(selected: Bool) { }

    public func setHighlighted(highlighted: Bool) { }
}

public final class RxCollectionViewCell<CONTENT: UIView>: UICollectionViewCell {
    private var content: CONTENT?

    public override var selected: Bool {
        didSet {
            if let content = content as? CollectionViewCellContent {
                content.setSelected(selected)
            }
        }
    }

    public override var highlighted: Bool {
        didSet {
            if let content = content as? CollectionViewCellContent {
                content.setHighlighted(highlighted)
            }
        }
    }

    public func cachedContentOrCreated(factory: () -> CONTENT) -> CONTENT {
        if let content = content {
            return content
        } else {
            let content = factory()
            self.content = content
            content >> contentView
            setNeedsUpdateConstraints()
            return content
        }
    }
    
    public override func updateConstraints() {
        super.updateConstraints()
        
        content?.snp_updateConstraints { make in
            make.edges.equalTo(contentView)
        }
    }
    
    public override class func requiresConstraintBasedLayout() -> Bool {
        return true
    }
}
