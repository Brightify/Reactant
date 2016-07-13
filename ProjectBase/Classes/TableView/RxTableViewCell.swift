//
//  RxTableViewCell.swift
//
//  Created by Tadeáš Kříž on 06/04/16.
//

import SwiftKit

final class RxTableViewCell<CONTENT: UIView>: UITableViewCell {
    private var content: CONTENT?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        loadView()
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        loadView()
    }

    private func loadView() {
        backgroundColor = nil
    }

    func cachedContentOrCreated(factory: () -> CONTENT) -> CONTENT {
        if let content = content {
            return content
        } else {
            let content = factory()
            self.content = content
            content >> contentView
            setNeedsUpdateConstraints()
            return content
        }
    }

    override func updateConstraints() {
        super.updateConstraints()

        content?.snp_updateConstraints { make in
            make.edges.equalTo(contentView)
        }
    }

    override class func requiresConstraintBasedLayout() -> Bool {
        return true
    }
}