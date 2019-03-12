//
//  FlowCollectionViewBase+Delegates.swift
//  Reactant
//
//  Created by Filip Dolnik on 13.02.17.
//  Copyright © 2017 Brightify. All rights reserved.
//

#if canImport(UIKit)
import UIKit

extension FlowCollectionViewBase {

    /**
     * The estimated size of cells in the collection view.
     * Providing an estimated cell size can improve the performance of the collection view when the cells adjust their size dynamically. Specifying an estimate value lets the collection view defer some of the calculations needed to determine the actual size of its content. Specifically, cells that are not onscreen are assumed to be the estimated height.
     * The default value of this property is CGSizeZero. Setting it to any other value causes the collection view to query each cell for its actual size using the cell’s **preferredLayoutAttributesFitting(_:)** method. If all of your cells are the same height, use the itemSize property, instead of this property, to specify the cell size instead.
     */
    public var estimatedItemSize: CGSize {
        get {
            return collectionViewLayout.estimatedItemSize
        }
        set {
            collectionViewLayout.estimatedItemSize = newValue
        }
    }

    /**
     * The default size to use for cells.
     * If the delegate does not implement the **collectionView(_:layout:sizeForItemAt:)** method, the flow layout uses the value in this property to set the size of each cell. This results in cells that all have the same size.
     * The default size value is (50.0, 50.0).
     */
    public var itemSize: CGSize {
        get {
            return collectionViewLayout.itemSize
        }
        set {
            collectionViewLayout.itemSize = newValue
        }
    }

    /**
     * The minimum spacing to use between lines of items in the grid.
     * If the delegate object does not implement the **collectionView(_:layout:minimumLineSpacingForSectionAt:)** method, the flow layout uses the value in this property to set the spacing between lines in a section.
     * For a vertically scrolling grid, this value represents the minimum spacing between successive rows. For a horizontally scrolling grid, this value represents the minimum spacing between successive columns. This spacing is not applied to the space between the header and the first line or between the last line and the footer.
     * The default value of this property is 10.0.
     */
    public var minimumLineSpacing: CGFloat {
        get {
            return collectionViewLayout.minimumLineSpacing
        }
        set {
            collectionViewLayout.minimumLineSpacing = newValue
        }
    }

    /**
     * The scroll direction of the grid.
     * The grid layout scrolls along one axis only, either horizontally or vertically. For the non scrolling axis, the width of the collection view in that dimension serves as starting width of the content.
     * The default value of this property is vertical.
     */
    public var scrollDirection: UICollectionView.ScrollDirection {
        get {
            return collectionViewLayout.scrollDirection
        }
        set {
            collectionViewLayout.scrollDirection = newValue
        }
    }
}
#endif
