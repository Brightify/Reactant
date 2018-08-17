//
//  SimpleCollectionView.swift
//  Reactant
//
//  Created by Filip Dolnik on 12.02.17.
//  Copyright © 2017 Brightify. All rights reserved.
//

import RxSwift

public enum SimpleCollectionViewAction<CELL: Component> {
    case selected(CELL.StateType)
    case cellAction(CELL.StateType, CELL.ActionType)
    case refresh
}

open class SimpleCollectionView<CELL: UIView>: FlowCollectionViewBase<CELL.StateType, SimpleCollectionViewAction<CELL>> where CELL: Component {
    
    public typealias MODEL = CELL.StateType
    
    private let cellIdentifier = CollectionViewCellIdentifier<CELL>()

    #if ENABLE_RXSWIFT
    open override var actions: [Observable<SimpleCollectionViewAction<CELL>>] {
        #if os(iOS)
        return [
            collectionView.rx.modelSelected(MODEL.self).map(SimpleCollectionViewAction.selected),
            refreshControl?.rx.controlEvent(.valueChanged).rewrite(with: SimpleCollectionViewAction.refresh)
        ].compactMap { $0 }
        #else
        return [
            collectionView.rx.modelSelected(MODEL.self).map(SimpleCollectionViewAction.selected)
        ]
        #endif
    }
    #endif
    
    private let cellFactory: () -> CELL
    
    public init(cellFactory: @escaping () -> CELL = CELL.init,
                reloadable: Bool = true,
                automaticallyDeselect: Bool = true) {
        self.cellFactory = cellFactory
        
        super.init(reloadable: reloadable, automaticallyDeselect: automaticallyDeselect)
    }
    
    open override func loadView() {
        super.loadView()
        
        collectionView.register(identifier: cellIdentifier)
    }

    #if ENABLE_RXSWIFT
    open override func bind(items: Observable<[MODEL]>) {
        items
            .bind(to: collectionView.items(with: cellIdentifier)) { [unowned self] row, model, cell in
                self.configure(cell: cell, factory: self.cellFactory, model: model, mapAction: { SimpleCollectionViewAction.cellAction(model, $0) })
            }
            .disposed(by: rx.lifetimeDisposeBag)
    }
    #endif
}
