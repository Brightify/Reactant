//
//  RxTableViewCell.swift
//
//  Created by Tadeáš Kříž on 06/04/16.
//

import SwiftKit

public protocol TableViewCellContent {

    var selectionStyle: UITableViewCellSelectionStyle { get }

    @available(iOS 9.0, *)
    var focusStyle: UITableViewCellFocusStyle { get }

    func setSelected(selected: Bool, animated: Bool)

    func setHighlighted(highlighted: Bool, animated: Bool)
}

extension TableViewCellContent {
    public var selectionStyle: UITableViewCellSelectionStyle {
        return .Default
    }

    @available(iOS 9.0, *)
    public var focusStyle: UITableViewCellFocusStyle {
        return .Default
    }
    
    public func setSelected(selected: Bool, animated: Bool) { }

    public func setHighlighted(highlighted: Bool, animated: Bool) { }
}

public final class RxTableViewCell<CONTENT: UIView>: UITableViewCell {
    private var content: CONTENT?

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

    public func cachedContentOrCreated(factory: () -> CONTENT) -> CONTENT {
        let cellContent: CONTENT
        if let content = content {
            cellContent = content
        } else {
            let content = factory()
            self.content = content
            content >> contentView
            setNeedsUpdateConstraints()
            cellContent = content
        }
        if let tableCellContent = cellContent as? TableViewCellContent {
            selectionStyle = tableCellContent.selectionStyle
            if #available(iOS 9.0, *) {
                focusStyle = tableCellContent.focusStyle
            }
        }
        return cellContent
    }

    public override func updateConstraints() {
        super.updateConstraints()

        content?.snp_updateConstraints { make in
            make.edges.equalTo(contentView)
        }
    }

    public override class func requiresConstraintBasedLayout() -> Bool {
        return true
    }

    public override func setSelected(selected: Bool, animated: Bool) {
        if let content = content as? TableViewCellContent {
            content.setSelected(selected, animated: animated)
        }
    }

    public override func setHighlighted(highlighted: Bool, animated: Bool) {
        if let content = content as? TableViewCellContent {
            content.setHighlighted(highlighted, animated: animated)
        }
    }
}