//
//  CollectionViewBase.swift
//  Reactant
//
//  Created by Filip Dolnik on 21.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import RxSwift

open class CollectionViewBase<MODEL, ACTION>: ViewBase<CollectionViewState<MODEL>, ACTION>, ReactantCollectionView, UICollectionViewDelegate {
    
    open var edgesForExtendedLayout: UIRectEdge {
        return .all
    }
    
    open override var configuration: Configuration {
        didSet {
            configuration.get(valueFor: Properties.Style.CollectionView.collectionView)(self)
            
            configurationChangeTime = clock()
            setNeedsLayout()
        }
    }
    
    public let collectionView: UICollectionView
    #if os(iOS)
    public let refreshControl: UIRefreshControl?
    #endif
    public let emptyLabel = UILabel()
    public let loadingIndicator = UIActivityIndicatorView()
    
    private let items = PublishSubject<[MODEL]>()
    // Optimization that prevents configuration reloading each time cell is dequeued.
    private var configurationChangeTime: clock_t = clock()
    
    private let automaticallyDeselect: Bool

    public init(layout: UICollectionViewLayout, reloadable: Bool = true, automaticallyDeselect: Bool = true) {
        self.collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        #if os(iOS)
        self.refreshControl = reloadable ? UIRefreshControl() : nil
        #endif
        
        self.automaticallyDeselect = automaticallyDeselect
        
        super.init()
    }
    
    open override func loadView() {
        children(
            collectionView,
            emptyLabel,
            loadingIndicator
        )
        #if os(iOS)
        if let refreshControl = refreshControl {
            collectionView.children(
                refreshControl
            )
        }
        #endif
        
        loadingIndicator.hidesWhenStopped = true
        
        collectionView.backgroundColor = .clear
        #if ENABLE_RXSWIFT
        collectionView.rx.setDelegate(self).disposed(by: rx.lifetimeDisposeBag)
        #else
        collectionView.delegate = self
        #endif
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
        if automaticallyDeselect {
            collectionView.rx.itemSelected
                .subscribe(onNext: { [collectionView] in
                    collectionView.deselectItem(at: $0, animated: true)
                })
                .disposed(by: rx.lifetimeDisposeBag)
        }

        bind(items: items)
    }

    open func bind(items: Observable<[MODEL]>) {
    }

    @available(*, unavailable, message: "RxSwift 3.0 changed behavior of DataSources so we have to bind only once. Use bind(items: Observable<MODEL>)")
    open func bind(items: [MODEL]) {
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
        #if os(iOS)
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
        #else
        if loading {
            loadingIndicator.startAnimating()
        } else {
            loadingIndicator.stopAnimating()
        }
        #endif

        self.items.onNext(items)

        setNeedsLayout()
    }
    
    open func configure<T: Component>(cell: CollectionViewCellWrapper<T>, factory: @escaping () -> T, model: T.StateType,
                          mapAction: @escaping (T.ActionType) -> ACTION) -> Void {
        #if ENABLE_RXSWIFT
        cell.configureDisposeBag = DisposeBag()
        #else
        cell.configureTracking = ObservationTokenTracker()
        #endif
        if configurationChangeTime != cell.configurationChangeTime {
            cell.configuration = configuration
            cell.configurationChangeTime = configurationChangeTime
        }
        let component = cell.cachedCellOrCreated(factory: factory)
        component.componentState = model
        #if ENABLE_RXSWIFT
        component.rx.action.map(mapAction)
            .subscribe(onNext: { [weak self] in
                self?.perform(action: $0)
            })
            .disposed(by: cell.configureDisposeBag)
        #else
        component
            .observeAction(observer: { [weak self] action in
                self?.perform(action: mapAction(action))
            })
            .track(in: cell.configureTracking)
        #endif
    }

    open func dequeueAndConfigure<T: Component>(identifier: CollectionViewCellIdentifier<T>,
                                                for indexPath: IndexPath,
                                                factory: @escaping () -> T,
                                                model: T.StateType,
                                                mapAction: @escaping (T.ActionType) -> ACTION) -> CollectionViewCellWrapper<T> {
        let cell = collectionView.dequeue(identifier: identifier, for: indexPath)
        configure(cell: cell, factory: factory, model: model, mapAction: mapAction)
        return cell
    }
    
    open func dequeueAndConfigure<T: Component>(identifier: CollectionViewCellIdentifier<T>,
                                                forRow row: Int,
                                                factory: @escaping () -> T,
                                                model: T.StateType,
                                                mapAction: @escaping (T.ActionType) -> ACTION) -> CollectionViewCellWrapper<T> {
        return dequeueAndConfigure(identifier: identifier,
                                   for: IndexPath(row: row, section: 0),
                                   factory: factory,
                                   model: model,
                                   mapAction: mapAction)
    }
    
    open func configure<T: Component>(view: CollectionReusableViewWrapper<T>, factory: @escaping () -> T, model: T.StateType,
                          mapAction: @escaping (T.ActionType) -> ACTION) -> Void {
        #if ENABLE_RXSWIFT
        view.configureDisposeBag = DisposeBag()
        #else
        view.configureTracking = ObservationTokenTracker()
        #endif
        if configurationChangeTime != view.configurationChangeTime {
            view.configuration = configuration
            view.configurationChangeTime = configurationChangeTime
        }
        let component = view.cachedViewOrCreated(factory: factory)
        component.componentState = model
        #if ENABLE_RXSWIFT
        component.rx.action.map(mapAction)
            .subscribe(onNext: { [weak self] in
                self?.perform(action: $0)
            })
            .disposed(by: view.configureDisposeBag)
        #else
        component
            .observeAction(observer: { [weak self] action in
                self?.perform(action: mapAction(action))
            })
            .track(in: view.configureTracking)
        #endif
    }

    open func dequeueAndConfigure<T: Component>(identifier: CollectionSupplementaryViewIdentifier<T>,
                                                for indexPath: IndexPath,
                                                factory: @escaping () -> T,
                                                model: T.StateType,
                                                mapAction: @escaping (T.ActionType) -> ACTION) -> CollectionReusableViewWrapper<T> {
        let view = collectionView.dequeue(identifier: identifier, for: indexPath)
        configure(view: view, factory: factory, model: model, mapAction: mapAction)
        return view
    }
    
    open func dequeueAndConfigure<T: Component>(identifier: CollectionSupplementaryViewIdentifier<T>,
                                                forRow row: Int,
                                                factory: @escaping () -> T,
                                                model: T.StateType,
                                                mapAction: @escaping (T.ActionType) -> ACTION) -> CollectionReusableViewWrapper<T> {
        return dequeueAndConfigure(identifier: identifier,
                                   for: IndexPath(row: row, section: 0),
                                   factory: factory,
                                   model: model,
                                   mapAction: mapAction)
    }
}

