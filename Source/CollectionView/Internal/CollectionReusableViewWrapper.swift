//
//  CollectionReusableViewWrapper.swift
//  Reactant
//
//  Created by Filip Dolnik on 14.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import UIKit

public final class CollectionReusableViewWrapper<VIEW: UIView>: UICollectionReusableView {
    
    private var wrappedView: VIEW?
    
    public override class var requiresConstraintBasedLayout: Bool {
        return true
    }
    
    public override func updateConstraints() {
        super.updateConstraints()
        
        wrappedView?.snp.updateConstraints { make in
            make.edges.equalTo(self)
        }
    }
    
    public func cachedViewOrCreated(factory: () -> VIEW) -> VIEW {
        if let wrappedView = wrappedView {
            return wrappedView
        } else {
            let wrappedView = factory()
            self.wrappedView = wrappedView
            children(wrappedView)
            setNeedsUpdateConstraints()
            return wrappedView
        }
    }
    
    public func deleteCachedView() -> VIEW? {
        let wrappedView = self.wrappedView
        wrappedView?.removeFromSuperview()
        self.wrappedView = nil
        return wrappedView
    }
}
