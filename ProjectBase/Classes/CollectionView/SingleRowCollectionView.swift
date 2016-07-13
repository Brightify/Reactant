//
//  SingleRowCollectionView.swift
//
//  Created by Maros Seleng on 10/05/16.
//

import Lipstick
import RxCocoa
import RxSwift

class SingleRowCollectionView<CELL: UIView where CELL: Component>: ViewBase<TableViewState<CELL.StateType>> {
    private typealias MODEL = CELL.StateType
    
    var modelSelected: ControlEvent<MODEL> {
        return collectionView.rx_modelSelected(MODEL)
    }
    
    override var edgesForExtendedLayout: UIRectEdge {
        return .All
    }
    
    private let collectionView: UICollectionView
    private let collectionViewLayout = UICollectionViewFlowLayout()
    private let emptyLabel = UILabel().styled(using: ProjectBaseConfiguration.global.labelStyle)
    private let loadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    
    private let cellFactory: () -> CELL
    
    init(
        cellFactory: () -> CELL,
        itemSize: CGSize = CGSizeZero,
        estimatedItemSize: CGSize = CGSizeZero,
        minimumLineSpacing: CGFloat = 0,
        horizontalInsets: CGFloat = 0,
        scrollDirection: UICollectionViewScrollDirection = .Horizontal)
    {
        self.collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: collectionViewLayout)
        self.cellFactory = cellFactory
        
        super.init()
        
        collectionViewLayout.itemSize = itemSize
        collectionViewLayout.estimatedItemSize = estimatedItemSize
        collectionViewLayout.minimumLineSpacing = minimumLineSpacing
        collectionViewLayout.scrollDirection = scrollDirection
        
        collectionView.backgroundColor = UIColor.clearColor()
        collectionView.contentInset = insets(horizontal: horizontalInsets, vertical: 0)
        collectionView.registerClass(RxCollectionViewCell<CELL>.self, forCellWithReuseIdentifier: "Cell")
    }
    
    override func loadView() {
        children(
            collectionView,
            emptyLabel,
            loadingIndicator
        )
        
        loadingIndicator.hidesWhenStopped = true
    }
    
    override func render() {
        var items: [MODEL] = []
        var loading: Bool = false
        var emptyMessage: String = ""
        
        switch componentState {
        case .Items(let models):
            items = models
        case .Empty(let message):
            emptyMessage = message
        case .Loading:
            loading = true
        }
        
        emptyLabel.text = emptyMessage
        
        if loading {
            loadingIndicator.startAnimating()
        } else {
            loadingIndicator.stopAnimating()
        }
        
        
        Observable.just(items)
            .bindTo(collectionView.rx_itemsWithCellIdentifier("Cell", cellType: RxCollectionViewCell<CELL>.self)) { [cellFactory] _, model, cell in
                cell.cachedContentOrCreated(cellFactory).setComponentState(model)
            }
            .addDisposableTo(stateDisposeBag)
        
        collectionView.rx_itemSelected
            .subscribeNext { [collectionView] in
                collectionView.deselectItemAtIndexPath($0, animated: true)
            }.addDisposableTo(stateDisposeBag)
        
        setNeedsLayout()
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        
        collectionView.snp_remakeConstraints { make in
            make.edges.equalTo(self)
        }
        
        emptyLabel.snp_remakeConstraints { make in
            make.center.equalTo(self)
        }
        
        loadingIndicator.snp_remakeConstraints { make in
            make.center.equalTo(self)
        }
    }
}
