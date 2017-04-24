import UIKit
import SnapKit
import Reactant
import KZFileWatchers
import SWXMLHash
import RxSwift

public class Watcher {
    public struct Error: Swift.Error {
        public let message: String
    }

    private let subject = PublishSubject<String>()
    private let path: String
    private let queue: DispatchQueue
    private let source: DispatchSourceFileSystemObject

    init(path: String, events: DispatchSource.FileSystemEvent = .write, queue: DispatchQueue = DispatchQueue.main) throws {
        self.path = path
        self.queue = queue

        let handle = open(path , O_EVTONLY)
        guard handle != -1 else {
            throw Error(message: "Failed to open file")
        }

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
    fileprivate let _typeName: String
    fileprivate let _xmlPath: String
    fileprivate var _properties: [String: Any] = [:]
    fileprivate var _selectionStyle: UITableViewCellSelectionStyle = .default
    fileprivate var _focusStyle: UITableViewCellFocusStyle = .default

    init(typeName: String, xmlPath: String) {
        _xmlPath = xmlPath
        _typeName = typeName
        super.init()
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
        return "AnonymousComponent: \(_typeName)"
    }
}

extension AnonymousComponent: ReactantUI {
    var rui: AnonymousComponent.RUIContainer {
        return Reactant.associatedObject(self, key: &AnonymousComponent.RUIContainer.associatedObjectKey) {
            return AnonymousComponent.RUIContainer(target: self)
        }
    }

    var __rui: Reactant.ReactantUIContainer {
        return rui
    }

    final class RUIContainer: Reactant.ReactantUIContainer {
        fileprivate static var associatedObjectKey = 0 as UInt8

        var xmlPath: String {
            return target?._xmlPath ?? "n/a"
        }

        var typeName: String {
            return target?._typeName ?? "n/a"
        }

        private weak var target: AnonymousComponent?

        fileprivate init(target: AnonymousComponent) {
            self.target = target
        }

        func setupReactantUI() {
            guard let target = self.target else { /* FIXME Should we fatalError here? */ return }
            ReactantLiveUIManager.shared.register(target)
        }

        func destroyReactantUI() {
            guard let target = self.target else { /* FIXME Should we fatalError here? */ return }
            ReactantLiveUIManager.shared.unregister(target)
        }
    }
}

extension AnonymousComponent: RootView {
    var edgesForExtendedLayout: UIRectEdge {
        return ReactantLiveUIManager.shared.extendedEdges(of: self)
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

final class PreviewListController: ControllerBase<Void, PreviewListRootView> {
    struct Dependencies {
        let manager: ReactantLiveUIManager
    }
    struct Reactions {
        let preview: (String) -> Void
        let close: () -> Void
    }

    private let dependencies: Dependencies
    private let reactions: Reactions

    private let closeButton = UIBarButtonItem(title: "Close", style: .done)

    init(dependencies: Dependencies, reactions: Reactions) {
        self.dependencies = dependencies
        self.reactions = reactions

        super.init(title: "Select view to preview")
    }

    override func afterInit() {
        navigationItem.leftBarButtonItem = closeButton
        closeButton.rx.tap
            .subscribe(onNext: reactions.close)
            .addDisposableTo(lifetimeDisposeBag)
    }

    override func update() {
        let items = dependencies.manager.allRegisteredDefinitionNames
        rootView.componentState = .items(items)
    }

    override func act(on action: PlainTableViewAction<PreviewListCell>) {
        switch action {
        case .refresh:
            dependencies.manager.reloadFiles()
            invalidate()
        case .selected(let path):
            reactions.preview(path)
        case .rowAction:
            break
        }
    }
}

final class PreviewListRootView: Reactant.PlainTableView<PreviewListCell>, RootView {
    override var edgesForExtendedLayout: UIRectEdge {
        return .all
    }

    init() {
        super.init(
            cellFactory: PreviewListCell.init,
            reloadable: true)

        rowHeight = UITableViewAutomaticDimension
        backgroundColor = .white
    }
}

final class PreviewListCell: ViewBase<String, Void> {
    private let name = UILabel()

    override func update() {
        name.text = componentState
    }

    override func loadView() {
        children(
            name
        )

        name.numberOfLines = 0
    }

    override func setupConstraints() {
        name.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.trailing.equalToSuperview().inset(20)
            make.top.greaterThanOrEqualToSuperview().inset(10)
            make.top.lessThanOrEqualToSuperview().inset(10)
            make.centerY.equalToSuperview()
        }
    }
}

final class PreviewController: ControllerBase<Void, PreviewRootView> {
    struct Parameters {
        let typeName: String
        let view: UIView
    }

    private let parameters: Parameters

    init(parameters: Parameters) {
        self.parameters = parameters

        super.init(title: "Previewing: \(parameters.typeName)",
                   root: PreviewRootView(previewing: parameters.view))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnTap = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.hidesBarsOnTap = false
    }
}

final class PreviewRootView: ViewBase<Void, Void>, RootView {
    private let previewing: UIView

    var edgesForExtendedLayout: UIRectEdge {
        return (previewing as? RootView)?.edgesForExtendedLayout ?? []
    }

    init(previewing: UIView) {
        self.previewing = previewing

        super.init()
    }

    override func loadView() {
        children(
            previewing
        )
    }

    override func setupConstraints() {
        previewing.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview().priority(UILayoutPriorityDefaultHigh)
        }
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

        let reloadFiles = UIAlertAction(title: "Reload files", style: .default) { _ in
            ReactantLiveUIManager.shared.reloadFiles()
        }
        controller.addAction(reloadFiles)
        let preview = UIAlertAction(title: "Preview ..", style: .default) { [weak self] _ in
            guard let controller = self?.rootViewController else { return }
            ReactantLiveUIManager.shared.presentPreview(in: controller)
        }
        controller.addAction(preview)
        controller.addAction(UIAlertAction(title: "Close menu", style: UIAlertActionStyle.cancel))

        controller.popoverPresentationController?.sourceView = self
        controller.popoverPresentationController?.sourceRect = bounds


        self.rootViewController?.present(controller: controller)
    }

}

public protocol ReactantLiveUIConfiguration {
    var rootDir: String { get }
    var componentTypes: [String: UIView.Type] { get }
    var commonStylePaths: [String] { get }
}

public class ReactantLiveUIManager {
    public static let shared = ReactantLiveUIManager()

    private var configuration: ReactantLiveUIConfiguration?
    private var watchers: [String: (watcher: Watcher, views: [WeakUIBox])] = [:]
    private var extendedEdges: [String: UIRectEdge] = [:]
    private var runtimeDefinitions: [String: String] = [:]
    private var definitions: [String: (definition: ComponentDefinition, loaded: Date, xmlPath: String)] = [:] {
        didSet {
            definitionsSubject.onNext(definitions)
        }
    }
    private let definitionsSubject = ReplaySubject<[String: (definition: ComponentDefinition, loaded: Date, xmlPath: String)]>.create(bufferSize: 1)

    private var styles: [String: StyleGroup] = [:] {
        didSet {
            resetErrors()
            let now = Date()
            var definitionsCopy = definitions
            for key in definitionsCopy.keys {
                definitionsCopy[key]?.loaded = now
            }
            definitions = definitionsCopy
        }
    }

    private let errorView = LiveUIErrorMessage().with(state: [:])
    private let disposeBag = DisposeBag()

    private weak var activeWindow: UIWindow?

    private init() { }

    public var commonStyles: [Style] {
        return styles.values.flatMap { $0.styles }
    }

    var allRegisteredDefinitionNames: [String] {
        let configurationNames: Set<String>
        if let configuration = configuration {
            configurationNames = Set(configuration.componentTypes.keys)
        } else {
            configurationNames = []
        }
        return configurationNames.union(runtimeDefinitions.keys).sorted()
    }

    public func activate(in window: UIWindow, configuration: ReactantLiveUIConfiguration) {
        self.configuration = configuration
        self.activeWindow = window
        errorView.removeFromSuperview()
        errorView.translatesAutoresizingMaskIntoConstraints = true
        window.addSubview(errorView)
        errorView.frame = window.bounds

        loadStyles(configuration.commonStylePaths)
    }

    public func extendedEdges<UI: UIView>(of view: UI) -> UIRectEdge where UI: ReactantUI {
        return extendedEdges[view.__rui.xmlPath] ?? []
    }

    public func reloadFiles() {
        guard let rootDir = configuration?.rootDir else { return }
        guard let enumerator = FileManager.default.enumerator(atPath: rootDir) else { return }
        for file in enumerator {
            guard let fileName = file as? String, fileName.hasSuffix(".ui.xml") else { continue }
            let path = rootDir + "/" + fileName
            if let configuration = configuration, configuration.componentTypes.keys.contains(path) { continue }
            do {
                let definitions = try self.definitions(in: path)
                for definition in definitions {
                    runtimeDefinitions[definition.type] = path
                }
            } catch let error {
                logError(error, in: path)
            }
        }
    }

    public func presentPreview(in controller: UIViewController) {
        let navigation = UINavigationController()
        let dependencies = PreviewListController.Dependencies(manager: self)
        let reactions = PreviewListController.Reactions(
            preview: { name in
                navigation.push(controller: self.preview(for: name))
            },
            close: {
                navigation.dismiss(animated: true)
            })
        let previewList = PreviewListController(dependencies: dependencies, reactions: reactions)
        navigation.push(controller: previewList)
        controller.present(controller: navigation)
    }

    private func preview(for name: String) -> PreviewController {
        let parameters = PreviewController.Parameters(
            typeName: name,
            // FIXME handle possible errors
            view: try! componentInstantiation(named: name)())
        return PreviewController(parameters: parameters)

    }

    private func definitions(in file: String) throws -> [ComponentDefinition] {
        let url = URL(fileURLWithPath: file)
        guard let data = try? Data(contentsOf: url, options: .uncached) else {
            throw TokenizationError(message: "ERROR: file not found")
        }
        let xml = SWXMLHash.parse(data)
        let rootDefinition = try xml["UI"].value() as ComponentDefinition

        if rootDefinition.isRootView {
            extendedEdges[file] = rootDefinition.edgesForExtendedLayout.resolveUnion()
        } else {
            extendedEdges.removeValue(forKey: file)
        }

        return rootDefinition.componentDefinitions
    }

    private func registerDefinitions(in file: String) throws {
        let definitions = try self.definitions(in: file)
        register(definitions: definitions, in: file)
    }

    internal func type(named name: String) -> UIView.Type? {
        return configuration?.componentTypes[name]
    }

    internal func componentInstantiation(named name: String) throws -> () -> UIView {
        if let precompiledType = configuration?.componentTypes[name] {
            return precompiledType.init
        } else if let definition = definitions[name] {
            return {
                AnonymousComponent(typeName: definition.definition.type, xmlPath: definition.xmlPath)
            }
        } else {
            throw TokenizationError(message: "Couldn't find type mapping for \(name)")
        }
    }

    internal func observeDefinition(for type: String) -> Observable<ComponentDefinition> {
        return definitionsSubject.map { $0[type] }
            .distinctUntilChanged { $0?.loaded == $1?.loaded }
            .filter { $0 != nil }.map { $0!.definition }

    }

    public func register<UI: UIView>(_ view: UI) where UI: ReactantUI {
        let xmlPath = view.__rui.xmlPath
        if !watchers.keys.contains(xmlPath) {
            let watcher: Watcher
            do {
                watcher = try Watcher(path: xmlPath)
            } catch let error {
                logError(error, in: xmlPath)
                return
            }

            watchers[xmlPath] = (watcher: watcher, views: [WeakUIBox(ui: view)])

            watcher.watch()
                .startWith(xmlPath)
                .subscribe(onNext: { path in
                    self.resetError(for: path)
                    do {
                        try self.registerDefinitions(in: path)

                        self.activeWindow?.topViewController()?.updateViewConstraints()
                    } catch let error {
                        self.logError(error, in: path)
                    }
                })
                .addDisposableTo(disposeBag)


        } else {
            watchers[xmlPath]?.views.append(WeakUIBox(ui: view))
        }

        observeDefinition(for: view.__rui.typeName)
            .takeUntil(view.rx.deallocated)
            .subscribe(onNext: { [weak view] definition in
                guard let view = view else { return }
                do {
                    try self.apply(definition: definition, view: view)
                } catch let error {
                    self.logError(error, in: xmlPath)
                }
            })
            .addDisposableTo(disposeBag)
    }

    public func unregister<UI: UIView>(_ ui: UI) where UI: ReactantUI {
        let xmlPath = ui.__rui.xmlPath
        guard let watcher = watchers[xmlPath] else {
            logError("ERROR: attempting to remove not registered UI", in: xmlPath)
            return
        }
        if watcher.views.count == 1 {
            watchers.removeValue(forKey: xmlPath)
        } else if let index = watchers[xmlPath]?.views.index(where: { $0.ui === ui }) {
            watchers[xmlPath]?.views.remove(at: index)
        }
    }

    private func loadStyles(_ stylePaths: [String]) {
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
                        // FIXME What to do with this?
//                        self.watchers.values.flatMap { $0.views }.forEach {
//                            guard let view = $0.view, let ui = $0.ui else { return }
//                            self.readAndApply(view: view, ui: ui)
//                        }
                    } catch let error {
                        self.logError(error, in: path)
                    }
                }
            }
        }
    }

    public func resetError(for path: String) {
        errorView.componentState.removeValue(forKey: path)
    }

    public func resetErrors() {
        errorView.componentState.removeAll()
    }

    public func logError(_ error: Error, in path: String) {
        switch error {
        case let liveUiError as LiveUIError:
            logError(liveUiError.message, in: path)
        case let tokenizationError as TokenizationError:
            logError(tokenizationError.message, in: path)
        case let deserializationError as XMLDeserializationError:
            logError(deserializationError.description, in: path)
        case let watcherError as Watcher.Error:
            logError(watcherError.message, in: path)
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

//    private func readAndApply(path xmlPath: String, views: [UIView]) {
//        let url = URL(fileURLWithPath: xmlPath)
//        guard let data = try? Data(contentsOf: url, options: .uncached) else {
//            logError("ERROR: file not found", in: xmlPath)
//            return
//        }
//
//        apply(data: data, views: views, xmlPath: xmlPath)
//    }

    private func register(definitions: [ComponentDefinition], in file: String) {
        var currentDefinitions = self.definitions
        for definition in definitions {
            currentDefinitions[definition.type] = (definition, Date(), file)
        }
        self.definitions = currentDefinitions
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
            register(definitions: definition.componentDefinitions, in: xmlPath)
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
