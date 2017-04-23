import UIKit
import SnapKit
import Reactant
import KZFileWatchers
import SWXMLHash
import RxSwift

public class Watcher {
    private let subject = PublishSubject<String>()
    private let path: String
    private let queue: DispatchQueue
    private let source: DispatchSourceFileSystemObject

    init(path: String, events: DispatchSource.FileSystemEvent = .write, queue: DispatchQueue = DispatchQueue.main) {
        self.path = path
        self.queue = queue

        let handle = open(path , O_EVTONLY)
        source = DispatchSource.makeFileSystemObjectSource(fileDescriptor: handle, eventMask: events, queue: queue)
        source.setEventHandler { [subject] in
            subject.onNext(path)
        }

        source.setCancelHandler { [subject] in
            close(handle)
            subject.onCompleted()
        }
    }

    func watch() -> Observable<String> {
        source.resume()
        return subject
    }

    deinit {
        source.cancel()
    }
}

class AnonymousComponent: ViewBase<Void, Void> {
    fileprivate let _definition: ComponentDefinition
    fileprivate var _properties: [String: Any] = [:]
    fileprivate var _selectionStyle: UITableViewCellSelectionStyle = .default
    fileprivate var _focusStyle: UITableViewCellFocusStyle = .default

    init(definition: ComponentDefinition) throws {
        _definition = definition
        super.init()

        try ReactantLiveUIApplier(definition: _definition,
                                  commonStyles: ReactantLiveUIManager.shared.commonStyles,
                                  instance: self).apply()
    }

    override func conforms(to aProtocol: Protocol) -> Bool {
        return super.conforms(to: aProtocol)
    }

    override func value(forUndefinedKey key: String) -> Any? {
        return _properties[key]
    }

    override func setValue(_ value: Any?, forUndefinedKey key: String) {
        _properties[key] = value
    }

    override var description: String {
        return "AnonymousComponent: \(_definition.type)"
    }
}

extension AnonymousComponent: RootView {
    var edgesForExtendedLayout: UIRectEdge {
        return _definition.edgesForExtendedLayout.resolveUnion()
    }
}

extension AnonymousComponent: TableViewCell {
    public var selectionStyle: UITableViewCellSelectionStyle {
        get {
            return _selectionStyle
        }
        set {
            _selectionStyle = newValue
        }
    }

    public var focusStyle: UITableViewCellFocusStyle {
        get {
            return _focusStyle
        }
        set {
            _focusStyle = newValue
        }
    }
}

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

class DebugAlertController: UIAlertController {
    override var canBecomeFirstResponder: Bool {
        return true
    }

    override var keyCommands: [UIKeyCommand]? {
        return [
            UIKeyCommand(input: "d", modifierFlags: .command, action: #selector(close), discoverabilityTitle: "Close Debug Menu")
        ]
    }

    func close() {
        dismiss(animated: true)
    }
}

extension UIWindow {
    override open var canBecomeFirstResponder: Bool {
        return true
    }

    override open var keyCommands: [UIKeyCommand]? {
        return [
            UIKeyCommand(input: "d", modifierFlags: .command, action: #selector(openDebugMenu), discoverabilityTitle: "Open Debug Menu")
        ]
    }

    func openDebugMenu() {
        let controller = DebugAlertController(title: "Debug menu", message: "Reactant Live UI", preferredStyle: .actionSheet)

        let reloadFiles = UIAlertAction(title: "Reload files", style: UIAlertActionStyle.default) { _ in

        }
        controller.addAction(reloadFiles)
        controller.addAction(UIAlertAction(title: "Close menu", style: UIAlertActionStyle.cancel))

        controller.popoverPresentationController?.sourceView = self
        controller.popoverPresentationController?.sourceRect = bounds


        self.rootViewController?.present(controller: controller)
    }

}

public protocol ReactantLiveUIConfiguration {
    var rootDir: String { get }
    var componentTypes: [String: UIView.Type] { get }
}

public class ReactantLiveUIManager {
    public static let shared = ReactantLiveUIManager()

    private var configuration: ReactantLiveUIConfiguration?
    private var watchers: [String: (watcher: Watcher, uis: [WeakUIBox])] = [:]
    private var extendedEdges: [String: UIRectEdge] = [:]

    private var styles: [String: StyleGroup] = [:]

    private let errorView = LiveUIErrorMessage().with(state: [:])
    private let disposeBag = DisposeBag()

    private weak var activeWindow: UIWindow?

    private init() { }

    public var commonStyles: [Style] {
        return styles.values.flatMap { $0.styles }
    }

    public func activate(in window: UIWindow, configuration: ReactantLiveUIConfiguration) {
        self.configuration = configuration
        self.activeWindow = window
        errorView.removeFromSuperview()
        errorView.translatesAutoresizingMaskIntoConstraints = true
        window.addSubview(errorView)
        errorView.frame = window.bounds
    }

    public func extendedEdges<UI: UIView>(of view: UI) -> UIRectEdge where UI: ReactantUI {
        return extendedEdges[view.__rui.xmlPath] ?? []
    }

//    public func register(component: UIView.Type, named: String) {
//        componentTypes[named] = component
//    }

    public func reloadFiles() {

    }

    internal func type(named name: String) -> UIView.Type? {
        return configuration?.componentTypes[name]
    }

    public func register<UI: UIView>(_ view: UI) where UI: ReactantUI {
        let xmlPath = view.__rui.xmlPath
        if watchers.keys.contains(xmlPath) {
            watchers[xmlPath]?.uis.append(WeakUIBox(ui: view))

            readAndApply(view: view)
        } else {
            let watcher = Watcher(path: xmlPath)
            watchers[xmlPath] = (watcher, [WeakUIBox(ui: view)])

            watcher.watch()
                .subscribe(onNext: { path in
                    self.logError(nil, in: xmlPath)
                    guard let watcher = self.watchers[xmlPath] else {
                        fatalError("Probably inconsistent state, got a file update with nonexistent watcher registration")
                    }

                    self.readAndApply(path: path, views: watcher.uis.flatMap { $0.view })
                })
                .addDisposableTo(disposeBag)
        }
    }

    public func unregister<UI: UIView>(_ ui: UI) where UI: ReactantUI {
        let xmlPath = ui.__rui.xmlPath
        guard let watcher = watchers[xmlPath] else {
            logError("ERROR: attempting to remove not registered UI", in: xmlPath)
            return
        }
        if watcher.uis.count == 1 {
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

    private func readAndApply(path xmlPath: String, views: [UIView]) {
        let url = URL(fileURLWithPath: xmlPath)
        guard let data = try? Data(contentsOf: url, options: .uncached) else {
            logError("ERROR: file not found", in: xmlPath)
            return
        }

        apply(data: data, views: views, xmlPath: xmlPath)
    }

    private func apply(data: Data, views: [UIView], xmlPath: String) {
        let xml = SWXMLHash.parse(data)
        var windows = [] as [UIWindow]
        do {
            let definition: ComponentDefinition = try xml["UI"].value()
            if definition.isRootView {
                extendedEdges[xmlPath] = definition.edgesForExtendedLayout.resolveUnion()
            } else {
                extendedEdges.removeValue(forKey: xmlPath)
            }
            try views.forEach {
                try apply(definition: definition, view: $0)
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

    private func apply(definition: ComponentDefinition, view: UIView) throws {
        try ReactantLiveUIApplier(definition: definition, commonStyles: commonStyles, instance: view).apply()
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
