//
//  TableViewCell.swift
//  Reactant
//
//  Created by Filip Dolnik on 13.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

#if os(iOS)
import UIKit

public protocol TableViewCell {
    
    var selectionStyle: UITableViewCellSelectionStyle { get }
    
    @available(iOS 9.0, *)
    var focusStyle: UITableViewCellFocusStyle { get }
    
    func setSelected(_ selected: Bool, animated: Bool)
    
    func setHighlighted(_ highlighted: Bool, animated: Bool)
}

extension TableViewCell {
    
    public var selectionStyle: UITableViewCellSelectionStyle {
        return .default
    }
    
    @available(iOS 9.0, *)
    public var focusStyle: UITableViewCellFocusStyle {
        return .default
    }
    
    public func setSelected(_ selected: Bool, animated: Bool) {
    }
    
    public func setHighlighted(_ highlighted: Bool, animated: Bool) {
    }
}
#endif
