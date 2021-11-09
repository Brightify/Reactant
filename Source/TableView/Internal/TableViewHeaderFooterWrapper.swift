//
//  TableViewHeaderFooterWrapper.swift
//  Reactant
//
//  Created by Filip Dolnik on 13.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import UIKit
import RxSwift

public final class TableViewHeaderFooterWrapper<VIEW: UIView>: UITableViewHeaderFooterView, Configurable {
    
    public var configurationChangeTime: clock_t = 0
    
    private var wrappedView: VIEW?
    
    public var reactantConfiguration: ReactantConfiguration = .global {
        didSet {
            (wrappedView as? Configurable)?.reactantConfiguration = reactantConfiguration
            reactantConfiguration.get(valueFor: Properties.Style.TableView.headerFooterWrapper)(self)
        }
    }

    public var configureDisposeBag = DisposeBag()
    
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
            (wrappedView as? Configurable)?.reactantConfiguration = reactantConfiguration
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
