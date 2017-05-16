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

    /**
     * The style of selected cells.
     * Use `UITableViewCellSelectionStyle` constants to set the value of the `selectionStyle` property.
     */
    var selectionStyle: UITableViewCellSelectionStyle { get }

    /**
     * The style of focused cells.
     * Use `UITableViewCellFocusStyle` constants to set the value of the `focusStyle` property.
     */
    @available(iOS 9.0, *)
    var focusStyle: UITableViewCellFocusStyle { get }

    /// Called after the user lifts the finger after tapping the cell.
    func setSelected(_ selected: Bool, animated: Bool)

    /// Called when user taps the cell.
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
