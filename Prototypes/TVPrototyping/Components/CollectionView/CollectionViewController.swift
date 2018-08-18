//
//  CollectionViewController.swift
//  TVPrototyping
//
//  Created by Matous Hybl on 03/11/2017.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Reactant
final class CollectionViewController: ControllerBase<Void, CollectionRootView> {

    override func afterInit() {
        rootView.componentState = .items(["Cell 1", "Cell 2", "Cell 3", "Cell 4", "Cell 5", "Cell 6"])

        tabBarItem = UITabBarItem(title: "Collection", image: nil, tag: 0)
    }

}

final class CollectionRootView: SimpleCollectionView<CollectionCell>, RootView {

    @objc
    init() {
        super.init(cellFactory: CollectionCell.init, reloadable: false)

        loadingIndicator.activityIndicatorViewStyle = .whiteLarge

        collectionView.allowsSelection = true
        collectionViewLayout.itemSize = CGSize(width: 400, height: 300)

        collectionView.rx.didUpdateFocusInContextWithAnimationCoordinator
            .subscribe(onNext: { [weak self] context, coordinator in
                self?.updateFocus(context: context, coordinator: coordinator)
            }).disposed(by: lifetimeDisposeBag)
    }



    func updateFocus(context: UICollectionViewFocusUpdateContext, coordinator: UIFocusAnimationCoordinator) {

        if let previousIndexPath = context.previouslyFocusedIndexPath,
            let cell = collectionView.cellForItem(at: previousIndexPath) {
            cell.contentView.layer.borderWidth = 0.0
            cell.contentView.layer.shadowRadius = 0.0
            cell.contentView.layer.shadowOpacity = 0
        }

        if let indexPath = context.nextFocusedIndexPath,
            let cell = collectionView.cellForItem(at: indexPath) {
            cell.contentView.layer.borderWidth = 8.0
            cell.contentView.layer.borderColor = UIColor.black.cgColor
            cell.contentView.layer.shadowColor = UIColor.black.cgColor
            cell.contentView.layer.shadowRadius = 10.0
            cell.contentView.layer.shadowOpacity = 0.9
            cell.contentView.layer.shadowOffset = CGSize(width: 0, height: 0)
            collectionView.scrollToItem(at: indexPath, at: [.centeredHorizontally, .centeredVertically], animated: true)
        }
    }

}

final class CollectionCell: ViewBase<String, Void> {

    private let label = UILabel()

    override var canBecomeFocused: Bool {
        return true
    }

    override func update() {
        label.text = componentState
    }

    override func loadView() {
        children(label)
    }

    override func setupConstraints() {
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
