//
//  Properties+CollectionView.swift
//  Reactant
//
//  Created by Filip Dolnik on 15.02.17.
//  Copyright © 2017 Brightify. All rights reserved.
//

#if canImport(UIKit)
import UIKit

extension Properties.Style {
    
    public struct CollectionView {
        
        public static let collectionView = Properties.Style.style(for: ReactantCollectionView.self)
        public static let reusableViewWrapper = Properties.Style.style(for: UICollectionReusableView.self)
        public static let cellWrapper = Properties.Style.style(for: UICollectionViewCell.self)
        public static let pageControl = Properties.Style.style(for: UIPageControl.self)
    }
}
#endif
