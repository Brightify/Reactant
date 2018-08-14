//
//  UIView+stack.swift
//  Reactant
//
//  Created by Matouš Hýbl on 02/04/2018.
//  Copyright © 2018 Brightify. All rights reserved.
//

import UIKit

public extension UIView {

    /**
     * Stacks views in superview horizontally or vertically with defined spacing
     * - parameter views: views to be layed out in the container
     * - parameter withSpacing: spacing to be put between views
     * - parameter axis: axis along which the views should be layed out
     * - parameter lowerPriorityOfLastConstraint: sets last constraint priority to high if true,
                                                  this prevents breaking of constraints in cases of hiding
                                                  the whole parent view using constraints
     */
    public func stack(views: [UIView],
                      withSpacing spacing: CGFloat = 0,
                      axis: NSLayoutConstraint.Axis = .horizontal,
                      lowerPriorityOfLastConstraint: Bool = false) {
        var previousView: UIView?
        let lastView = views.last
        for view in views {
            view.removeFromSuperview()
            addSubview(view)
            switch axis {
            case .horizontal:
                view.snp.makeConstraints { make in
                    if let previousView = previousView {
                        make.leading.equalTo(previousView.snp.trailing).offset(spacing)
                    } else {
                        make.leading.equalToSuperview()
                    }

                    make.top.bottom.equalToSuperview()
                    if view === lastView {
                        make.trailing.equalToSuperview().priority(lowerPriorityOfLastConstraint ? .high : .required)
                    }
                }
            case .vertical:
                view.snp.makeConstraints { make in
                    if let previousView = previousView {
                        make.top.equalTo(previousView.snp.bottom).offset(spacing)
                    } else {
                        make.top.equalToSuperview()
                    }

                    make.leading.trailing.equalToSuperview()
                    if view === lastView {
                        make.bottom.equalToSuperview().priority(lowerPriorityOfLastConstraint ? .high : .required)
                    }
                }
            }

            previousView = view
        }
    }
}
