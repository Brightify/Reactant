//
//  SimpleCollectionView.swift
//  Reactant
//
//  Created by Filip Dolnik on 12.02.17.
//  Copyright © 2017 Brightify. All rights reserved.
//

import UIKit

public enum SimpleCollectionViewAction<CELL: Component> {
    case selected(CELL.StateType)
    case cellAction(CELL.StateType, CELL.ActionType)
    case refresh
}

open class SimpleCollectionView<CELL: UIView>: FlowCollectionViewBase<CELL.StateType, SimpleCollectionViewAction<CELL>>, UICollectionViewDataSource where CELL: Component {

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

        collectionView.dataSource = self
    }

    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard case .items(let items) = componentState else { return 0 }
        return items.count
    }

    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard case .items(let items) = componentState else {
            fatalError("Invalid state! This is developer error.")
        }

        let model = items[indexPath.row]
        return dequeueAndConfigure(
            identifier: cellIdentifier,
            for: indexPath,
            factory: cellFactory,
            model: model,
            mapAction: { SimpleCollectionViewAction.cellAction(model, $0) })
    }

    open override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard case .items(let items) = componentState else { return }

        perform(action: .selected(items[indexPath.row]))
    }

    open override func performRefresh() {
        super.performRefresh()

        perform(action: .refresh)
    }
}
