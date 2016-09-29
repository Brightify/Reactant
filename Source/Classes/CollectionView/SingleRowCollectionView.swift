//
//  SingleRowCollectionView.swift
//
//  Created by Maros Seleng on 10/05/16.
//

import Lipstick
import RxCocoa
import RxSwift

public class SingleRowCollectionView<CELL: UIView>: ViewBase<TableViewState<CELL.StateType>> where CELL: Component {
    private typealias MODEL = CELL.StateType
    
    public var modelSelected: ControlEvent<MODEL> {
        return collectionView.rx.modelSelected(MODEL.self)
    }
    
    public override var edgesForExtendedLayout: UIRectEdge {
        return .all
    }
    
    public let collectionView: UICollectionView
    public let collectionViewLayout = UICollectionViewFlowLayout()
    private let emptyLabel = UILabel().styled(using: ReactantConfiguration.global.emptyListLabelStyle)
    private let loadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    private let cellFactory: () -> CELL
    
    public init(
        cellFactory: @escaping () -> CELL,
        itemSize: CGSize = CGSize.zero,
        estimatedItemSize: CGSize = CGSize.zero,
        minimumLineSpacing: CGFloat = 0,
        horizontalInsets: CGFloat = 0,
        scrollDirection: UICollectionViewScrollDirection = .horizontal)
    {
        self.collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: collectionViewLayout)
        self.cellFactory = cellFactory
        
        super.init()
        
        collectionViewLayout.itemSize = itemSize
        collectionViewLayout.estimatedItemSize = estimatedItemSize
        collectionViewLayout.minimumLineSpacing = minimumLineSpacing
        collectionViewLayout.scrollDirection = scrollDirection
        
        collectionView.backgroundColor = UIColor.clear
        collectionView.contentInset = insets(horizontal: horizontalInsets, vertical: 0)
        collectionView.register(RxCollectionViewCell<CELL>.self, forCellWithReuseIdentifier: "Cell")
    }
    
    public override func loadView() {
        children(
            collectionView,
            emptyLabel,
            loadingIndicator
        )
        
        loadingIndicator.hidesWhenStopped = true
    }
    
    public override func render() {
        var items: [MODEL] = []
        var loading: Bool = false
        var emptyMessage: String = ""
        
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
            .bindTo(collectionView.rx.items(cellIdentifier: "Cell", cellType: RxCollectionViewCell<CELL>.self)) { [cellFactory] _, model, cell in
                cell.cachedContentOrCreated(factory: cellFactory).setComponentState(model)
            }
            .addDisposableTo(stateDisposeBag)
        
        collectionView.rx.itemSelected
            .subscribe(onNext: { [collectionView] in
                collectionView.deselectItem(at: $0, animated: true)
            })
            .addDisposableTo(stateDisposeBag)
        
        setNeedsLayout()
    }
    
    public override func updateConstraints() {
        super.updateConstraints()
        
        collectionView.snp.remakeConstraints { make in
            make.edges.equalTo(self)
        }
        
        emptyLabel.snp.remakeConstraints { make in
            make.center.equalTo(self)
        }
        
        loadingIndicator.snp.remakeConstraints { make in
            make.center.equalTo(self)
        }
    }
}
