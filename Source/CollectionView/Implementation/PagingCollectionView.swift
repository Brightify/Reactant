//
//  PagingCollectionView.swift
//  Reactant
//
//  Created by Filip Dolnik on 16.02.17.
//  Copyright © 2017 Brightify. All rights reserved.
//

#if canImport(UIKit)
import UIKit

open class PagingCollectionView<CELL: UIView>: SimpleCollectionView<CELL> where CELL: _Component {
    
    open override var configuration: Configuration {
        didSet {
            configuration.get(valueFor: Properties.Style.CollectionView.pageControl)(pageControl)
        }
    }
    
    open var showPageControl: Bool {
        get {
            return pageControl.visibility == .visible
        }
        set {
            pageControl.visibility = newValue ? .visible : .hidden
        }
    }
    
    public let pageControl = UIPageControl()
    
    public override init(cellFactory: @escaping () -> CELL = CELL.init, reloadable: Bool = true, automaticallyDeselect: Bool = true) {
        super.init(cellFactory: cellFactory, reloadable: reloadable, automaticallyDeselect: automaticallyDeselect)
    }
    
    open override func loadView() {
        super.loadView()
        
        children(
            pageControl
        )

        #if os(iOS)
        collectionView.isPagingEnabled = true
        #endif
        collectionView.showsHorizontalScrollIndicator = false
        collectionViewLayout.scrollDirection = .horizontal
        collectionViewLayout.minimumLineSpacing = 0
    }
    
    open override func setupConstraints() {
        super.setupConstraints()
        
        pageControl.snp.makeConstraints { make in
            make.width.equalTo(self)
            make.bottom.equalTo(8)
        }
    }

    open override func update(items: [CELL.StateType]) {
        pageControl.numberOfPages = items.count
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        
        itemSize = collectionView.bounds.size
    }
    
    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        pageControl.currentPage = Int(collectionView.contentOffset.x / itemSize.width)
    }
}
#endif
