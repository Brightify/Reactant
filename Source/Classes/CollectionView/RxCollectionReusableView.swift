//
//  RxCollectionViewHeader.swift
//
//  Created by Maros Seleng on 10/05/16.
//

import SwiftKit

public final class RxCollectionReusableView<CONTENT: UIView>: UICollectionReusableView {
    private var content: CONTENT?

    open override class var requiresConstraintBasedLayout: Bool {
        return true
    }
    
    open func cachedContentOrCreated(factory: () -> CONTENT) -> CONTENT {
        if let content = content {
            return content
        } else {
            let content = factory()
            self.content = content
            children(content)
            setNeedsUpdateConstraints()
            return content
        }
    }
    
    open override func updateConstraints() {
        super.updateConstraints()
        
        content?.snp.updateConstraints { make in
            make.edges.equalTo(self)
        }
    }
}
