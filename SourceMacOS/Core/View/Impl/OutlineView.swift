import RxSwift
import Cocoa

public enum OutlineViewItem<T> {
    indirect case node(T, items: [OutlineViewItem<T>])
    // TODO We need a better name
    case leaf(T)

    public var value: T {
        switch self {
        case .node(let item, _):
            return item
        case .leaf(let item):
            return item
        }
    }
}

public enum OutlineViewAction<T> {
    case selected(OutlineViewItem<T>)
}

open class OutlineView<T>: ViewBase<[OutlineViewItem<T>], OutlineViewAction<T>>, NSOutlineViewDataSource, NSOutlineViewDelegate {
    public typealias ObjectValueTransform<T> = (T) -> Any?
    public let scrollView = NSScrollView()
    public let outlineView = NSOutlineView()
    public let tableColumn = NSTableColumn(identifier: "OutlineViewColumn")

    private let objectValue: ObjectValueTransform<T>

    public init(title: String, objectValue: @escaping ObjectValueTransform<T>) {
        self.objectValue = objectValue
        self.tableColumn.title = title
        super.init()
    }

    open override func update() {
        outlineView.reloadData()
    }

    open override func loadView() {
        children(
            scrollView
        )

        scrollView.documentView = outlineView
        outlineView.autoresizingMask = [.viewWidthSizable, .viewHeightSizable]

        outlineView.dataSource = self
        outlineView.delegate = self
        outlineView.addTableColumn(tableColumn)
        outlineView.outlineTableColumn = tableColumn

        tableColumn.isEditable = false
        tableColumn.minWidth = 150
    }

    open override func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    public func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if let possibleItem = item {
            guard let item = possibleItem as? OutlineViewItem<T> else { return 0 }
            switch item {
            case .node(_, let items):
                return items.count
            case .leaf:
                return 0
            }
        } else {
            return componentDelegate.hasComponentState ? componentState.count : 0
        }
    }

    public func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if let possibleItem = item {
            guard let item = possibleItem as? OutlineViewItem<T> else { return Optional<OutlineViewItem<T>>.none as Any }
            switch item {
            case .node(_, let items):
                return items[index]
            case .leaf:
                return Optional<OutlineViewItem<T>>.none as Any
            }
        } else {
            return componentState[index]
        }
    }

    public func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        guard let item = item as? OutlineViewItem<T> else { return false }
        switch item {
        case .node:
            return true
        case .leaf:
            return false
        }
    }

    public func outlineView(_ outlineView: NSOutlineView, objectValueFor tableColumn: NSTableColumn?, byItem item: Any?) -> Any? {
        guard let item = item as? OutlineViewItem<T> else { return nil }
        return objectValue(item.value)
    }

    public func outlineViewSelectionDidChange(_ notification: Notification) {
        let selectedIndex = outlineView.selectedRow
        guard componentState.indices ~= selectedIndex else { return }
        let item = componentState[selectedIndex]
        perform(action: .selected(item))
    }
}
