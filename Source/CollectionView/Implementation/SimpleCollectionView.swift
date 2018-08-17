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

    open override func actionMapping(mapper: ActionMapper<ActionType>) {
        mapper.passthrough(collectionView.rx.modelSelected(MODEL.self).map(SimpleCollectionViewAction.selected))

        #if os(iOS)
        if let refreshControl = refreshControl {
            mapper.passthrough(refreshControl.rx.controlEvent(.valueChanged).rewrite(with: SimpleCollectionViewAction.refresh))
        }
        #endif
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
