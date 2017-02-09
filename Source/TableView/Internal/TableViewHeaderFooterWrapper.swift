//
//  TableViewHeaderFooterWrapper.swift
//  Reactant
//
//  Created by Filip Dolnik on 13.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import UIKit

public final class TableViewHeaderFooterWrapper<VIEW: UIView>: UITableViewHeaderFooterView {
    
    private var wrappedView: VIEW?
    
    public override class var requiresConstraintBasedLayout: Bool {
        return true
    }
    
    public override func updateConstraints() {
        super.updateConstraints()
        
        wrappedView?.snp.updateConstraints { make in
            make.edges.equalTo(contentView)
        }
    }
    
    public func cachedViewOrCreated(factory: () -> VIEW) -> VIEW {
        if let wrappedView = wrappedView {
            return wrappedView
        } else {
            let wrappedView = factory()
            self.wrappedView = wrappedView
            contentView.children(wrappedView)
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
