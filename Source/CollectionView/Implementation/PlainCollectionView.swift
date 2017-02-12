//
//  PlainCollectionView.swift
//  Reactant
//
//  Created by Filip Dolnik on 12.02.17.
//  Copyright © 2017 Brightify. All rights reserved.
//

import RxSwift
import RxCocoa

public enum PlainCollectionViewAction<CELL: Component> {
    case selected(CELL.StateType)
    case cellAction(CELL.StateType, CELL.ActionType)
    case refresh
}

open class PlainCollectionView<CELL: UIView>: ViewBase<CollectionViewState<CELL.StateType>, PlainCollectionViewAction<CELL>>, ReactantCollectionView where CELL: Component {
    
    public typealias MODEL = CELL.StateType
    
    private let cellIdentifier = CollectionViewCellIdentifier<CELL>()
    
    open var edgesForExtendedLayout: UIRectEdge {
        return .all
    }
    
    open override var actions: [Observable<PlainCollectionViewAction<CELL>>] {
        return [
            collectionView.rx.modelSelected(MODEL.self).map(PlainCollectionViewAction.selected),
            refreshControl?.rx.controlEvent(.valueChanged).rewrite(with: PlainCollectionViewAction.refresh)
        ].flatMap { $0 }
    }
    
    public let collectionView: UICollectionView
    public let collectionViewLayout = UICollectionViewFlowLayout()
    
    public let refreshControl: UIRefreshControl?
    public let emptyLabel = UILabel()
    public let loadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: ReactantConfiguration.global.loadingIndicatorStyle)
    
    private let cellFactory: () -> CELL
    
    // TODO Test crash.
    public init(cellFactory: @escaping () -> CELL = CELL.init, reloadable: Bool = true) {
        self.collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: collectionViewLayout)
        self.refreshControl = reloadable ? UIRefreshControl() : nil
        self.cellFactory = cellFactory
        
        super.init()
    }
    
    open override func loadView() {
        children(
            collectionView,
            emptyLabel,
            loadingIndicator
        )
        
        if let refreshControl = refreshControl {
            collectionView.children(
                refreshControl
            )
        }
        
        loadingIndicator.hidesWhenStopped = true
        
        ReactantConfiguration.global.emptyListLabelStyle(emptyLabel)
        
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = true
        
        collectionView.register(identifier: cellIdentifier)
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
    
    open override func afterInit() {
        collectionView.rx.itemSelected
            .subscribe(onNext: { [collectionView] in
                collectionView.deselectItem(at: $0, animated: true)
            })
            .addDisposableTo(lifetimeDisposeBag)
    }
    
    open override func update() {
        var items: [MODEL] = []
        var emptyMessage = ""
        var loading = false
        
        switch componentState {
        case .items(let models):
            items = models
        case .empty(let message):
            emptyMessage = message
        case .loading:
            loading = true
        }
        
        emptyLabel.text = emptyMessage
        
        if let refreshControl = refreshControl {
            if loading {
                refreshControl.beginRefreshing()
            } else {
                refreshControl.endRefreshing()
            }
        } else {
            if loading {
                loadingIndicator.startAnimating()
            } else {
                loadingIndicator.stopAnimating()
            }
        }
        
        Observable.just(items)
            .bindTo(collectionView.items(with: cellIdentifier)) { [cellFactory] _, model, cell in
                let component = cell.cachedCellOrCreated(factory: cellFactory)
                component.componentState = model
                component.action.subscribe(onNext: { [weak self] in
                    self?.perform(action: .cellAction(model, $0))
                })
                .addDisposableTo(component.stateDisposeBag)
            }
            .addDisposableTo(stateDisposeBag)
        
        setNeedsLayout()
    }
}
