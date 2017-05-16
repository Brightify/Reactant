//
//  TableViewCellWrapper.swift
//  Reactant
//
//  Created by Filip Dolnik on 13.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

#if os(iOS)
import UIKit

public final class TableViewCellWrapper<CELL: UIView>: UITableViewCell, Configurable {
    
    public var configurationChangeTime: clock_t = 0
    
    private var cell: CELL?
    
    public var configuration: Configuration = .global {
        didSet {
            (cell as? Configurable)?.configuration = configuration
            configuration.get(valueFor: Properties.Style.TableView.cellWrapper)(self)
        }
    }
    
    public override class var requiresConstraintBasedLayout: Bool {
        return true
    }
    
    private var tableViewCell: TableViewCell? {
        return cell as? TableViewCell
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        loadView()
    }
    
    public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        loadView()
    }
    
    private func loadView() {
        backgroundColor = nil
        backgroundView = nil
        selectedBackgroundView = nil
        multipleSelectionBackgroundView = nil
    }

    public override func updateConstraints() {
        super.updateConstraints()
        
        cell?.snp.updateConstraints { make in
            make.edges.equalTo(contentView)
        }
    }
    
    public override func setSelected(_ selected: Bool, animated: Bool) {
        tableViewCell?.setSelected(selected, animated: animated)
    }
    
    public override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        tableViewCell?.setHighlighted(highlighted, animated: animated)
    }
    
    public func cachedCellOrCreated(factory: () -> CELL) -> CELL {
        if let cell = cell {
            return cell
        } else {
            let cell = factory()
            (cell as? Configurable)?.configuration = configuration
            self.cell = cell
            if let tableViewCell = tableViewCell {
                selectionStyle = tableViewCell.selectionStyle
                if #available(iOS 9.0, *) {
                    focusStyle = tableViewCell.focusStyle
                }
            }
            contentView.children(cell)
            setNeedsUpdateConstraints()
            return cell
        }
    }
    
    public func deleteCachedCell() -> CELL? {
        let cell = self.cell
        cell?.removeFromSuperview()
        self.cell = nil
        return cell
    }
}
#endif
