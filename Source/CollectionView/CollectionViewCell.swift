//
//  CollectionViewCell.swift
//  Reactant
//
//  Created by Filip Dolnik on 14.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

#if canImport(UIKit)
import UIKit

public protocol CollectionViewCell {
    
    func setSelected(_ selected: Bool)
    
    func setHighlighted(_ highlighted: Bool)
}

extension CollectionViewCell {
    /// Called after the user lifts the finger after tapping the cell.
    public func setSelected(_ selected: Bool) {
    }

    /// Called when user taps the cell.
    public func setHighlighted(_ highlighted: Bool) {
    }
}
#endif
