import UIKit
import SnapKit

public class ReactantLiveUIManager {
    public static func test() {
        print("ReactantLiveUI!!!")
    }
}

extension Array where Element == (String, UIView) {
    func named(_ name: String) -> UIView {
        return first(where: { $0.0 == name })!.1
    }
}

public class ReactantLiveUIApplier {
    let root: Element.Root
    let instance: UIView

    private var tempCounter: Int = 1

    public init(root: Element.Root, instance: UIView) {
        self.root = root
        self.instance = instance
    }

    public func apply() {
        instance.subviews.forEach { $0.removeFromSuperview() }
        let views = root.children.flatMap { apply(element: $0, superview: instance) }
        tempCounter = 1
        root.children.forEach { applyConstraints(views: views, element: $0, superview: instance) }
    }

    private func apply(element: UIElement, superview: UIView) -> [(String, UIView)] {
        let name: String
        let view: UIView
        if let field = element.field {
            name = "\(field)"
            view = instance.value(forKey: field) as! UIView
        } else if let layoutId = element.layout.id {
            name = "named_\(layoutId)"
            view = element.initialize()
        } else {
            name = "temp_\(type(of: element))_\(tempCounter)"
            tempCounter += 1
            view = element.initialize()
        }

        element.propertyAssignment(instance: view)

        superview.addSubview(view)

        if let container = element as? UIContainer {
            let children = container.children.flatMap { apply(element: $0, superview: view) }

            return [(name, view)] + children
        } else {
            return [(name, view)]
        }
    }

    private func applyConstraints(views: [(String, UIView)], element: UIElement, superview: UIView) {
        let name: String
        if let field = element.field {
            name = "\(field)"
        } else if let layoutId = element.layout.id {
            name = "named_\(layoutId)"
        } else {
            name = "temp_\(type(of: element))_\(tempCounter)"
            tempCounter += 1
        }

        let view = views.named(name)

        view.snp.remakeConstraints { make in
            for constraint in element.layout.constraints {
                let maker: ConstraintMakerExtendable
                switch constraint.anchor {
                case .top:
                    maker = make.top
                case .bottom:
                    maker = make.bottom
                case .leading:
                    maker = make.leading
                case .trailing:
                    maker = make.trailing
                case .left:
                    maker = make.left
                case .right:
                    maker = make.right
                case .width:
                    maker = make.width
                case .height:
                    maker = make.height
                }

                let target: ConstraintRelatableTarget

                if let targetConstant = Float(constraint.target), constraint.anchor == .width || constraint.anchor == .height {
                    target = targetConstant
                } else {
                    let targetView = constraint.target != "super" ? views.named(constraint.target) : superview
                    if constraint.targetAnchor != constraint.anchor {
                        switch constraint.targetAnchor {
                        case .top:
                            target = targetView.snp.top
                        case .bottom:
                            target = targetView.snp.bottom
                        case .leading:
                            target = targetView.snp.leading
                        case .trailing:
                            target = targetView.snp.trailing
                        case .left:
                            target = targetView.snp.left
                        case .right:
                            target = targetView.snp.right
                        case .width:
                            target = targetView.snp.width
                        case .height:
                            target = targetView.snp.height
                        }
                    } else {
                        target = targetView
                    }
                }

                var editable: ConstraintMakerEditable
                switch constraint.relation {
                case .equal:
                    editable = maker.equalTo(target)
                case .greaterThanOrEqual:
                    editable = maker.greaterThanOrEqualTo(target)
                case .lessThanOrEqual:
                    editable = maker.lessThanOrEqualTo(target)
                }

                if constraint.constant != 0 {
                    editable = editable.offset(constraint.constant)
                }
                if constraint.multiplier != 1 {
                    editable = editable.multipliedBy(constraint.multiplier)
                }
                if constraint.priority.numeric != 1000 {
                    editable.priority(constraint.priority.numeric)
                }
            }
        }

        if let container = element as? UIContainer {
            container.children.forEach { applyConstraints(views: views, element: $0, superview: view) }
        }
    }
}
