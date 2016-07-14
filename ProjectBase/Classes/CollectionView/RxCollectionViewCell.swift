//
//  RxCollectionViewCell.swift
//
//  Created by Maros Seleng on 10/05/16.
//
import SwiftKit

public final class RxCollectionViewCell<CONTENT: UIView>: UICollectionViewCell {
    private var content: CONTENT?
    
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
