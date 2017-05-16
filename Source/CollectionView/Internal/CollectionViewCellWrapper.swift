//
//  CollectionViewCellWrapper.swift
//  Reactant
//
//  Created by Filip Dolnik on 14.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

#if os(iOS)
import UIKit
import RxSwift

public final class CollectionViewCellWrapper<CELL: UIView>: UICollectionViewCell, Configurable {
    
    public var configurationChangeTime: clock_t = 0
    
    private var cell: CELL?
    
    public var configuration: Configuration = .global {
        didSet {
            (cell as? Configurable)?.configuration = configuration
            configuration.get(valueFor: Properties.Style.CollectionView.cellWrapper)(self)
        }
    }
    
    public override class var requiresConstraintBasedLayout: Bool {
        return true
    }

    public override var preferredFocusedView: UIView? {
        return cell
    }

    @available(iOS 9.0, tvOS 9.0, *)
    public override var preferredFocusEnvironments: [UIFocusEnvironment] {
        return cell.map { [$0] } ?? []
    }
    
    private var collectionViewCell: CollectionViewCell? {
        return cell as? CollectionViewCell
    }
    
    public override var isSelected: Bool {
        didSet {
            collectionViewCell?.setSelected(isSelected)
        }
    }

    public var configureDisposeBag = DisposeBag()
    
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
            (cell as? Configurable)?.configuration = configuration
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
#endif
