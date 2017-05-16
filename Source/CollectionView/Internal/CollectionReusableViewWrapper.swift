//
//  CollectionReusableViewWrapper.swift
//  Reactant
//
//  Created by Filip Dolnik on 14.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

#if os(iOS)
import UIKit

public final class CollectionReusableViewWrapper<VIEW: UIView>: UICollectionReusableView, Configurable {
    
    public var configurationChangeTime: clock_t = 0
    
    private var wrappedView: VIEW?
        
    public var configuration: Configuration = .global {
        didSet {
            (wrappedView as? Configurable)?.configuration = configuration
            configuration.get(valueFor: Properties.Style.CollectionView.reusableViewWrapper)(self)
        }
    }
    
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
            (wrappedView as? Configurable)?.configuration = configuration
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
#endif
