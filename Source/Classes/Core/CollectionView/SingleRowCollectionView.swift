//
//  SingleRowCollectionView.swift
//  Reactant
//
//  Created by Maros Seleng on 10/05/16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import RxCocoa
import RxSwift

open class SingleRowCollectionView<CELL: UIView>: ViewBase<CollectionViewState<CELL.StateType>> where CELL: Component {
    
    private typealias MODEL = CELL.StateType
    
    private let identifier = CollectionViewCellIdentifier<CELL>()
    
    open var modelSelected: ControlEvent<MODEL> {
        return collectionView.rx.modelSelected(MODEL.self)
    }
    
    open var edgesForExtendedLayout: UIRectEdge {
        return .all
    }
    
    open let collectionView: UICollectionView
    open let collectionViewLayout = UICollectionViewFlowLayout()
    
    private let emptyLabel = UILabel()
    private let loadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    private let cellFactory: () -> CELL
    
    // TODO Test crash.
    public init(cellFactory: @escaping () -> CELL = CELL.init) {
        self.collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: collectionViewLayout)
        self.cellFactory = cellFactory
        
        super.init()
    }
    
    open override func loadView() {
        children(
            collectionView,
            emptyLabel,
            loadingIndicator
        )
        
        loadingIndicator.hidesWhenStopped = true
        
        collectionViewLayout.itemSize = CGSize.zero
        collectionViewLayout.minimumLineSpacing = 0
        collectionViewLayout.scrollDirection = .horizontal
        collectionView.backgroundColor = UIColor.clear
        collectionView.register(identifier: identifier)
        
        ReactantConfiguration.global.emptyListLabelStyle(emptyLabel)
    }
    
    open override func setupConstraints() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
        
        emptyLabel.snp.makeConstraints { make in
            make.center.equalTo(self)
        }
        
        loadingIndicator.snp.makeConstraints { make in
            make.center.equalTo(self)
        }
    }
    
    public func afterInit() {
        collectionView.rx.itemSelected
            .subscribe(onNext: { [collectionView] in
                    collectionView.deselectItem(at: $0, animated: true)
                })
            .addDisposableTo(lifetimeDisposeBag)
    }
    
    public func componentStateDidChange() {
        var items: [MODEL] = []
        var emptyMessage: String = ""
        var loading: Bool = false
        
        switch componentState {
        case .items(let models):
            items = models
        case .empty(let message):
            emptyMessage = message
        case .loading:
            loading = true
        }
        
        emptyLabel.text = emptyMessage
        
        if loading {
            loadingIndicator.startAnimating()
        } else {
            loadingIndicator.stopAnimating()
        }
        
        Observable.just(items)
            .bindTo(collectionView.items(with: identifier)) { [cellFactory] _, model, cell in
                cell.cachedCellOrCreated(factory: cellFactory).setComponentState(model)
            }
            .addDisposableTo(stateDisposeBag)

        setNeedsLayout()
    }
}
