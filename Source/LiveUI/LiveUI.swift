import UIKit
import SnapKit
import Reactant
import KZFileWatchers
import SWXMLHash

private struct WeakUIBox {
    weak var ui: ReactantUI?
    /// Workaround for non-existent class existentials
    weak var view: UIView?
    
    init<UI: UIView>(ui: UI) where UI: ReactantUI {
        self.ui = ui
        self.view = ui
    }
}

extension WeakUIBox: Equatable {
    
    static func ==(lhs: WeakUIBox, rhs: WeakUIBox) -> Bool {
        return lhs.ui === rhs.ui
    }
}

public class ReactantLiveUIManager {
    
    public static let shared = ReactantLiveUIManager()
    
    private var watchers: [String: (watcher: FileWatcherProtocol, uis: [WeakUIBox])] = [:]
    
    public func register<UI: UIView>(_ ui: UI) where UI: ReactantUI {
        if watchers.keys.contains(ui.uiXmlPath) {
            watchers[ui.uiXmlPath]?.uis.append(WeakUIBox(ui: ui))
            
            readAndApply(ui: ui)
        } else {
            let watcher = FileWatcher.Local(path: ui.uiXmlPath)
            watchers[ui.uiXmlPath] = (watcher, [WeakUIBox(ui: ui)])
            
            try! watcher.start { result in
                switch result {
                case .noChanges:
                    break
                case .updated(let data):
                    self.watchers[ui.uiXmlPath]?.uis
                        .flatMap { $0.view }
                        .forEach { self.apply(data: data, ui: $0) }
                }
            }
        }
    }
    
    public func unregister<UI: UIView>(_ ui: UI) where UI: ReactantUI {
        guard let watcher = watchers[ui.uiXmlPath] else {
            print("ERROR: attempting to remove not registered UI")
            return
        }
        if watcher.uis.count == 1 {
            try! watcher.watcher.stop()
            watchers.removeValue(forKey: ui.uiXmlPath)
        } else if let index = watchers[ui.uiXmlPath]?.uis.index(where: { $0.ui === ui }) {
            watchers[ui.uiXmlPath]?.uis.remove(at: index)
        }
    }
    
    private func apply(data: Data, ui: UIView) {
        let xml = SWXMLHash.parse(data)
        do {
            let root: Element.Root = try xml["UI"].value()
            ReactantLiveUIApplier(root: root, instance: ui).apply()
        } catch let error {
            print(error)
        }
    }
    
    private func readAndApply<UI: UIView>(ui: UI) where UI: ReactantUI {
        let url = URL(fileURLWithPath: ui.uiXmlPath)
        guard let data = try? Data(contentsOf: url, options: .uncached) else {
            print("ERROR: file not found")
            return
        }
        
        apply(data: data, ui: ui)
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

        for (key, value) in element.properties {
            guard view.responds(to: Selector(key)) else {
                print("!! View `\(view)` doesn't respond to selector `\(key)` to set value `\(value)`")
                continue
            }
            if let objectValue = value.value as? AnyObject {
                var mutableObject: AnyObject? = objectValue
                do {
                    try view.validateValue(&mutableObject, forKey: key)
                    view.setValue(mutableObject, forKey: key)
                } catch {
                    print("!! Value `\(value)` isn't valid for key `\(key)` on view `\(view)")
                    continue
                }
            } else {
                print("!! Value `\(value)` cannot be set to `\(key)` as it's not Objc compatible. View: `\(view)`")
            }
        }

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
                case .centerX:
                    maker = make.centerX
                case .centerY:
                    maker = make.centerY
                case .firstBaseline:
                    maker = make.firstBaseline
                case .lastBaseline:
                    maker = make.lastBaseline
                }

                let target: ConstraintRelatableTarget

                if let targetConstant = Float(constraint.target), constraint.anchor == .width || constraint.anchor == .height {
                    target = targetConstant
                } else {
                    let targetName: String
                    if let colonIndex = constraint.target.characters.index(of: ":"), constraint.target.substring(to: colonIndex) == "id" {
                        targetName = "named_\(constraint.target.substring(from: constraint.target.characters.index(after: colonIndex)))"
                    } else {
                        targetName = constraint.target
                    }
                    let targetView = targetName != "super" ? views.named(targetName) : superview
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
                        case .centerX:
                            target = targetView.snp.centerX
                        case .centerY:
                            target = targetView.snp.centerY
                        case .firstBaseline:
                            target = targetView.snp.firstBaseline
                        case .lastBaseline:
                            target = targetView.snp.lastBaseline
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
