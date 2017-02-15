//
//  Properties+CollectionView.swift
//  Reactant
//
//  Created by Filip Dolnik on 15.02.17.
//  Copyright © 2017 Brightify. All rights reserved.
//

import UIKit

extension Properties {
    
    public static let emptyListLabelStyle = Property<(UILabel) -> Void>(defaultValue: { _ in })
    public static let loadingIndicatorStyle = Property<UIActivityIndicatorViewStyle>(defaultValue: .gray)
}
