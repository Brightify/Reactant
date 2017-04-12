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

extension UIWindow {
    func topViewController() -> UIViewController? {
        return rootViewController.map(topViewController)
    }

    private func topViewController(with root: UIViewController) -> UIViewController {
        if let selectedController = (root as? UITabBarController)?.selectedViewController {
            return topViewController(with: selectedController)
        } else if let visibleController = (root as? UINavigationController)?.visibleViewController {
            return topViewController(with: visibleController)
        } else {
            return root.presentedViewController.map(topViewController) ?? root
        }
    }
}

public class ReactantLiveUIManager {
    
    public static let shared = ReactantLiveUIManager()
    private var componentTypes: [String: UIView.Type] = [:]
    private var watchers: [String: (watcher: FileWatcherProtocol, uis: [WeakUIBox])] = [:]
    private var extendedEdges: [String: UIRectEdge] = [:]

    private let scrollView = UIScrollView()
    private let errorLabel = UILabel()

    init() {
        let errorContainer = ContainerView()
        scrollView.addSubview(errorContainer)
        scrollView.backgroundColor = .red

        errorContainer.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        errorLabel.textColor = .white
        errorLabel.numberOfLines = 0
        errorLabel.textAlignment = .center
        errorContainer.addSubview(errorLabel)
        errorLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.trailing.equalToSuperview().inset(16)

            make.top.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(16)
        }
        UIApplication.shared.keyWindow?.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()

            make.top.equalToSuperview()
            make.bottom.equalToSuperview().priority(UILayoutPriorityDefaultLow)
        }
        scrollView.visibility = .collapsed
    }

    public func extendedEdges<UI: UIView>(of view: UI) -> UIRectEdge where UI: ReactantUI {
        return extendedEdges[view.uiXmlPath] ?? []
    }

    public func register(component: UIView.Type, named: String) {
        componentTypes[named] = component
    }

    internal func type(named name: String) -> UIView.Type? {
        return componentTypes[name]
    }

    public func register<UI: UIView>(_ view: UI) where UI: ReactantUI {
        if watchers.keys.contains(view.uiXmlPath) {
            watchers[view.uiXmlPath]?.uis.append(WeakUIBox(ui: view))
            
            readAndApply(view: view)
        } else {
            let watcher = FileWatcher.Local(path: view.uiXmlPath)
            watchers[view.uiXmlPath] = (watcher, [WeakUIBox(ui: view)])
            
            try! watcher.start { result in
                switch result {
                case .noChanges:
                    break
                case .updated(let data):
                    self.scrollView.visibility = .collapsed
                    guard let watcher = self.watchers[view.uiXmlPath] else {
                        fatalError("Probably inconsistent state, got a file update with")
                    }
                    self.apply(data: data, views: watcher.uis.flatMap { $0.view }, xmlPath: view.uiXmlPath)
                }
            }
        }
    }
    
    public func unregister<UI: UIView>(_ ui: UI) where UI: ReactantUI {
        guard let watcher = watchers[ui.uiXmlPath] else {
            error("ERROR: attempting to remove not registered UI")
            return
        }
        if watcher.uis.count == 1 {
            try! watcher.watcher.stop()
            watchers.removeValue(forKey: ui.uiXmlPath)
        } else if let index = watchers[ui.uiXmlPath]?.uis.index(where: { $0.ui === ui }) {
            watchers[ui.uiXmlPath]?.uis.remove(at: index)
        }
    }

    public func error(_ error: String) {
        print(error)
        errorLabel.text = error

        scrollView.visibility = .visible
        UIApplication.shared.keyWindow?.bringSubview(toFront: scrollView)
    }

    private func apply(data: Data, views: [UIView], xmlPath: String) {
        let xml = SWXMLHash.parse(data)
        var windows = [] as [UIWindow]
        do {
            let root: Element.Root = try xml["UI"].value()
            if root.isRootView {
                extendedEdges[xmlPath] = root.edgesForExtendedLayout.resolveUnion()
            } else {
                extendedEdges.removeValue(forKey: xmlPath)
            }
            views.forEach {
                apply(root: root, view: $0)
                if let window = $0.window, !windows.contains(window) {
                    windows.append(window)
                }
            }
            windows.forEach {
                $0.topViewController()?.updateViewConstraints()
            }
        } catch let error {
            print(error)
        }
    }
    
    private func apply(root: Element.Root, view: UIView) {
        do {
            try ReactantLiveUIApplier(root: root, instance: view).apply()
            if let invalidable = view as? Invalidable {
                invalidable.invalidate()
            }
        } catch let error {
            if let uiError = error as? LiveUIError {
                ReactantLiveUIManager.shared.error(uiError.message)
            }
        }
    }
    
    private func readAndApply<UI: UIView>(view: UI) where UI: ReactantUI {
        let url = URL(fileURLWithPath: view.uiXmlPath)
        guard let data = try? Data(contentsOf: url, options: .uncached) else {
            error("ERROR: file not found")
            return
        }
        
        apply(data: data, views: [view], xmlPath: view.uiXmlPath)
    }

}

extension Array where Element == (String, UIView) {
    func named(_ name: String) -> UIView? {
        return first(where: { $0.0 == name })?.1
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

    public func apply() throws {
        instance.subviews.forEach { $0.removeFromSuperview() }
        let views = try root.children.flatMap { try apply(element: $0, superview: instance) }
        tempCounter = 1
        try root.children.forEach { try applyConstraints(views: views, element: $0, superview: instance) }
    }

    private func apply(element: UIElement, superview: UIView) throws -> [(String, UIView)] {
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

        do {
            for property in try root.styles.resolveStyle(for: element) {
                property.apply(property, view)
            }
        } catch let error {
            print(error)
        }

        // FIXME This is a workaround, should not be doing it here (could move to the UIContainer)
        if let stackView = superview as? UIStackView {
            stackView.addArrangedSubview(view)
        } else {
            superview.addSubview(view)
        }

        if let container = element as? UIContainer {
            let children = try container.children.flatMap { try apply(element: $0, superview: view) }

            return [(name, view)] + children
        } else {
            return [(name, view)]
        }
    }

    private func applyConstraints(views: [(String, UIView)], element: UIElement, superview: UIView) throws {
        let name: String
        if let field = element.field {
            name = "\(field)"
        } else if let layoutId = element.layout.id {
            name = "named_\(layoutId)"
        } else {
            name = "temp_\(type(of: element))_\(tempCounter)"
            tempCounter += 1
        }

        guard let view = views.named(name) else {
            throw LiveUIError(message: "Couldn't find view with name \(name) in view hierarchy")
            return
        }

        var error: LiveUIError?

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
                    guard let targetView = targetName != "super" ? views.named(targetName) : superview else {
                        error = LiveUIError(message: "Couldn't find view with name \(targetName) in view hierarchy")
                        return
                    }
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

        if let error = error {
            throw error
        }

        if let container = element as? UIContainer {
            try container.children.forEach { try applyConstraints(views: views, element: $0, superview: view) }
        }
    }
}

public struct LiveUIError: Error {
    let message: String
}

