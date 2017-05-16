//
//  CollectionViewCell.swift
//  Reactant
//
//  Created by Filip Dolnik on 14.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

#if os(iOS)
import UIKit

public protocol CollectionViewCell {
    
    func setSelected(_ selected: Bool)
    
    func setHighlighted(_ highlighted: Bool)
}

extension CollectionViewCell {
    
    public func setSelected(_ selected: Bool) {
    }
    
    public func setHighlighted(_ highlighted: Bool) {
    }
}
#endif
