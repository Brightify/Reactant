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
    private var componentTypes: [String: UIView.Type] = [:]
    private var watchers: [String: (watcher: FileWatcherProtocol, uis: [WeakUIBox])] = [:]
    private var extendedEdges: [String: UIRectEdge] = [:]

    private var styles: [String: StyleGroup] = [:]

    private let errorView = LiveUIErrorMessage().with(state: [:])

    private weak var activeWindow: UIWindow?

    private init() { }

    public func setActiveWindow(_ window: UIWindow) {
        self.activeWindow = window
        errorView.removeFromSuperview()
        errorView.translatesAutoresizingMaskIntoConstraints = true
        window.addSubview(errorView)
        errorView.frame = window.bounds
    }

    public func extendedEdges<UI: UIView>(of view: UI) -> UIRectEdge where UI: ReactantUI {
        return extendedEdges[view.__rui.xmlPath] ?? []
    }

    public func register(component: UIView.Type, named: String) {
        componentTypes[named] = component
    }

    internal func type(named name: String) -> UIView.Type? {
        return componentTypes[name]
    }

    public func register<UI: UIView>(_ view: UI) where UI: ReactantUI {
        let xmlPath = view.__rui.xmlPath
        if watchers.keys.contains(xmlPath) {
            watchers[xmlPath]?.uis.append(WeakUIBox(ui: view))

            readAndApply(view: view)
        } else {
            let watcher = FileWatcher.Local(path: xmlPath)
            watchers[xmlPath] = (watcher, [WeakUIBox(ui: view)])

            try! watcher.start { result in
                switch result {
                case .noChanges:
                    break
                case .updated(let data):
                    self.logError(nil, in: xmlPath)
                    guard let watcher = self.watchers[xmlPath] else {
                        fatalError("Probably inconsistent state, got a file update with")
                    }
                    self.apply(data: data, views: watcher.uis.flatMap { $0.view }, xmlPath: xmlPath)
                }
            }
        }
    }

    public func unregister<UI: UIView>(_ ui: UI) where UI: ReactantUI {
        let xmlPath = ui.__rui.xmlPath
        guard let watcher = watchers[xmlPath] else {
            logError("ERROR: attempting to remove not registered UI", in: xmlPath)
            return
        }
        if watcher.uis.count == 1 {
            try! watcher.watcher.stop()
            watchers.removeValue(forKey: xmlPath)
        } else if let index = watchers[xmlPath]?.uis.index(where: { $0.ui === ui }) {
            watchers[xmlPath]?.uis.remove(at: index)
        }
    }

    public func loadStyles(_ stylePaths: [String]) {
        guard self.styles.isEmpty else {
            return
        }
        for path in stylePaths {
            let watcher = FileWatcher.Local(path: path)
            try! watcher.start { result in
                switch result {
                case .noChanges:
                    break
                case .updated(let data):
                    let xml = SWXMLHash.parse(data)
                    do {
                        let group: StyleGroup = try xml["styleGroup"].value()
                        self.styles[group.name] = group
                        self.watchers.values.flatMap { $0.uis }.forEach {
                            guard let view = $0.view, let ui = $0.ui else { return }
                            self.readAndApply(view: view, ui: ui)
                        }
                    } catch let error {
                        self.logError(error, in: path)
                    }
                }
            }
        }
    }

    public func logError(_ error: Error, in path: String) {
        switch error {
        case let liveUiError as LiveUIError:
            logError(liveUiError.message, in: path)
        case let tokenizationError as TokenizationError:
            logError(tokenizationError.message, in: path)
        case let deserializationError as XMLDeserializationError:
            logError(deserializationError.description, in: path)
        default:
            logError(error.localizedDescription, in: path)
        }
    }

    public func logError(_ error: String?, in path: String) {
        print(error ?? "")

        if let error = error {
            errorView.componentState[path] = error
        } else {
            errorView.componentState.removeValue(forKey: path)
        }
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
            try views.forEach {
                try apply(root: root, view: $0)
                if let window = $0.window, !windows.contains(window) {
                    windows.append(window)
                }
            }
            windows.forEach {
                $0.topViewController()?.updateViewConstraints()
            }
        } catch let error {
            logError(error, in: xmlPath)
        }
    }

    private func apply(root: Element.Root, view: UIView) throws {
        try ReactantLiveUIApplier(root: root, commonStyles: styles.values.flatMap { $0.styles }, instance: view).apply()
        if let invalidable = view as? Invalidable {
            invalidable.invalidate()
        }
    }

    private func readAndApply<UI: UIView>(view: UI) where UI: ReactantUI {
        readAndApply(view: view, ui: view)
    }

    private func readAndApply(view: UIView, ui: ReactantUI) {
        let xmlPath = ui.__rui.xmlPath
        let url = URL(fileURLWithPath: xmlPath)
        guard let data = try? Data(contentsOf: url, options: .uncached) else {
            logError("ERROR: file not found", in: xmlPath)
            return
        }

        apply(data: data, views: [view], xmlPath: xmlPath)
    }

}
