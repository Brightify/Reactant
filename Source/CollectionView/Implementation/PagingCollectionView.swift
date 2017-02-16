//
//  PagingCollectionView.swift
//  Reactant
//
//  Created by Filip Dolnik on 16.02.17.
//  Copyright © 2017 Brightify. All rights reserved.
//

import RxSwift

public enum PagingCollectionViewAction<CELL: Component> {
    case selected(CELL.StateType)
    case cellAction(CELL.StateType, CELL.ActionType)
    case refresh
}

open class PagingCollectionView<CELL: UIView>: FlowCollectionViewBase<CELL.StateType, PagingCollectionViewAction<CELL>> where CELL: Component {
    
    public typealias MODEL = CELL.StateType
    
    private let cellIdentifier = CollectionViewCellIdentifier<CELL>()
    
    open override var actions: [Observable<PagingCollectionViewAction<CELL>>] {
        return [
            collectionView.rx.modelSelected(MODEL.self).map(PagingCollectionViewAction.selected),
            refreshControl?.rx.controlEvent(.valueChanged).rewrite(with: PagingCollectionViewAction.refresh)
        ].flatMap { $0 }
    }
    
    open override var configuration: Configuration {
        didSet {
            configuration.get(valueFor: Properties.Style.CollectionView.pageControl)(pageControl)
        }
    }
    
    public let pageControl = UIPageControl()
    
    private let cellFactory: () -> CELL
    
    public init(cellFactory: @escaping () -> CELL = CELL.init, reloadable: Bool = true) {
        self.cellFactory = cellFactory
        
        super.init(reloadable: reloadable)
    }
    
    open override func loadView() {
        super.loadView()
        
        children(
            pageControl
        )
        
        collectionView.register(identifier: cellIdentifier)
    }
    
    open override func setupConstraints() {
        super.setupConstraints()
        
        // TODO Adjust
        pageControl.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
    }
    
    open override func bind(items: [MODEL]) {
        pageControl.rx.controlEvent(.valueChanged)
            .map { [pageControl] in
                pageControl.currentPage
            }
            .distinctUntilChanged()
            .flatMap { [unowned self] page in
                Observable.just(self.items(forPage: page, items: items))
            }.bindTo(collectionView.items(with: cellIdentifier)) { [unowned self] row, model, cell in
                self.configure(cell: cell, factory: self.cellFactory, model: model, mapAction: { PagingCollectionViewAction.cellAction(model, $0) })
            }.addDisposableTo(stateDisposeBag)
    }
    
    open func items(forPage page: Int, items: [MODEL]) -> [MODEL] {
        if pageControl.numberOfPages <= 1 || items.count < 1 {
            return items
        } else {
            let from: Int
            let to: Int
            if items.count % pageControl.numberOfPages == 0 {
                let itemsPerPage = items.count / pageControl.numberOfPages
                from = itemsPerPage * page
                to = itemsPerPage * (page + 1)
            } else {
                let itemsPerPage = (items.count - 1) / (pageControl.numberOfPages - 1)
                if page == pageControl.numberOfPages - 1 {
                    from = itemsPerPage * (pageControl.numberOfPages - 1)
                    to = items.count
                } else {
                    from = itemsPerPage * page
                    to = itemsPerPage * (page + 1)
                }
            }
            var result: [MODEL] = []
            for i in from..<to {
                result.append(items[i])
            }
            return result
        }
    }
}
