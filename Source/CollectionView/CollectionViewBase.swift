//
//  CollectionViewBase.swift
//  Reactant
//
//  Created by Filip Dolnik on 21.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import RxSwift

open class CollectionViewBase<MODEL, ACTION>: ViewBase<CollectionViewState<MODEL>, ACTION>, UICollectionViewDelegate {
    
    open var edgesForExtendedLayout: UIRectEdge {
        return .all
    }
    
    open override var configuration: Configuration {
        didSet {
            configuration.get(valueFor: Properties.Style.CollectionView.collectionView)(collectionView)
            if let refreshControl = refreshControl {
                configuration.get(valueFor: Properties.Style.CollectionView.refreshControl)(refreshControl)
            }
            configuration.get(valueFor: Properties.Style.CollectionView.emptyLabel)(emptyLabel)
            configuration.get(valueFor: Properties.Style.CollectionView.loadingIndicator)(loadingIndicator)
            
            configurationChangeTime = clock()
            setNeedsLayout()
        }
    }
    
    public let collectionView: UICollectionView
    
    public let refreshControl: UIRefreshControl?
    public let emptyLabel = UILabel()
    public let loadingIndicator = UIActivityIndicatorView()
    
    // Optimization that prevents configuration reloading each time cell is dequeued.
    private var configurationChangeTime: clock_t = clock()
    
    public init(layout: UICollectionViewLayout, reloadable: Bool = true) {
        self.collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        self.refreshControl = reloadable ? UIRefreshControl() : nil
        
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
        
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = true
        collectionView.delegate = self
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
        
        bind(items: items)
        
        setNeedsLayout()
    }
    
    open func bind(items: [MODEL]) {
    }
    
    open func configure<T: Component>(cell: CollectionViewCellWrapper<T>, factory: @escaping () -> T, model: T.StateType,
                          mapAction: @escaping (T.ActionType) -> ACTION) -> Void {
        if configurationChangeTime != cell.configurationChangeTime {
            cell.configuration = configuration
            cell.configurationChangeTime = configurationChangeTime
        }
        let component = cell.cachedCellOrCreated(factory: factory)
        component.componentState = model
        component.action.map(mapAction)
            .subscribe(onNext: perform)
            .addDisposableTo(component.stateDisposeBag)
    }
    
    open func dequeueAndConfigure<T: Component>(identifier: CollectionViewCellIdentifier<T>, forRow row: Int, factory: @escaping () -> T,
                                    model: T.StateType, mapAction: @escaping (T.ActionType) -> ACTION) -> CollectionViewCellWrapper<T> {
        let cell = collectionView.dequeue(identifier: identifier, forRow: row)
        configure(cell: cell, factory: factory, model: model, mapAction: mapAction)
        return cell
    }
    
    open func configure<T: Component>(view: CollectionReusableViewWrapper<T>, factory: @escaping () -> T, model: T.StateType,
                          mapAction: @escaping (T.ActionType) -> ACTION) -> Void {
        if configurationChangeTime != view.configurationChangeTime {
            view.configuration = configuration
            view.configurationChangeTime = configurationChangeTime
        }
        let component = view.cachedViewOrCreated(factory: factory)
        component.componentState = model
        component.action.map(mapAction)
            .subscribe(onNext: perform)
            .addDisposableTo(component.stateDisposeBag)
    }
    
    open func dequeueAndConfigure<T: Component>(identifier: CollectionSupplementaryViewIdentifier<T>, forRow row: Int, factory: @escaping () -> T,
                                    model: T.StateType, mapAction: @escaping (T.ActionType) -> ACTION) -> CollectionReusableViewWrapper<T> {
        let view = collectionView.dequeue(identifier: identifier, forRow: row)
        configure(view: view, factory: factory, model: model, mapAction: mapAction)
        return view
    }
}

