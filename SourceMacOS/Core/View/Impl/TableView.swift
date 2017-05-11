import Cocoa
import RxSwift

public enum TableViewAction<ITEM, ACTION> {
    case selected(ITEM)
    case cellAction(ACTION)
}

public struct Columns {
    public static func label<ITEM, ACTION>(
        _ id: String = UUID().uuidString,
        title: String,
        width: CGFloat? = nil,
        resizingMask: NSTableColumnResizingOptions? = nil,
        text: @escaping (ITEM) -> String) -> TableColumn<ITEM, ACTION, Label> {

        return TableColumn(
            identifier: id,
            title: title,
            setupColumn: { column in
                if let width = width {
                    column.width = width
                }
                if let resizingMask = resizingMask {
                    column.resizingMask = resizingMask
                }
            },
            makeView: {
                let label = Label()
                label.lineBreakMode = .byTruncatingTail
                return label
            },
            setComponentState: { item, view in
                view.stringValue = text(item)
            },
            action: { _ in nil })
    }

    public static func checkbox<ITEM, ACTION>(
        _ id: String = UUID().uuidString,
        title: String,
        value: @escaping (ITEM) -> Bool,
        action: @escaping (ITEM, Button) -> Observable<ACTION>? = { _ in nil }) -> TableColumn<ITEM, ACTION, Button> {

        return TableColumn(
            identifier: id,
            title: title,
            setupColumn: { column in
                column.resizingMask = []
                column.sizeToFit()
            },
            makeView: {
                let button = Button()
                button.title = ""
                button.setButtonType(.switch)
                button.isEnabled = false
                return button
            },
            setComponentState: { item, view in
                view.state = value(item) ? NSOnState : NSOffState
            },
            action: action)
    }
}

public struct TableColumn<ITEM, ACTION, VIEW: View> {
    let identifier: String
    let title: String
    let setupColumn: (NSTableColumn) -> Void
    let makeView: () -> VIEW
    let setComponentState: (ITEM, VIEW) -> Void
    let action: (ITEM, VIEW) -> Observable<ACTION>?

    func typeErased() -> AnyTableColumn<ITEM, ACTION> {
        let actionSubject = PublishSubject<ACTION>()
        var disposeBags = [:] as [ObjectIdentifier: DisposeBag]
        return AnyTableColumn(
            identifier: identifier,
            makeView: makeView,
            setComponentState: { [setComponentState, action] item, possibleView in
                guard let view = possibleView as? VIEW else {
                    fatalError("Wrong view type! Got \(type(of: possibleView)), expected \(VIEW.self)!")
                }
                setComponentState(item, view)
                let identifier = ObjectIdentifier(view)
                let disposeBag: DisposeBag
                if let storedBag = disposeBags[identifier] {
                    disposeBag = storedBag
                } else {
                    disposeBag = DisposeBag()
                    disposeBags[identifier] = disposeBag
                }
                action(item, view)?.subscribe(onNext: {
                    actionSubject.onNext($0)
                }).disposed(by: disposeBag)
            },
            action: actionSubject)
    }
}

public struct AnyTableColumn<ITEM, ACTION> {
    let identifier: String
    let makeView: () -> View
    let setComponentState: (ITEM, View) -> Void
    let action: Observable<ACTION>?
}

open class TableView<ITEM, ACTION>: ViewBase<[ITEM], TableViewAction<ITEM, ACTION>>, NSTableViewDataSource, NSTableViewDelegate {
    open override var actions: [Observable<TableViewAction<ITEM, ACTION>>] {
        return columns.values.flatMap {
            $0.action?.map(TableViewAction.cellAction)
        }
    }

    public let scrollView = NSScrollView()
    public let tableView = NSTableView()

    private var columns: [String: AnyTableColumn<ITEM, ACTION>] = [:]

    open override func update() {
        tableView.reloadData()
    }

    public func addTableColumn<VIEW>(_ column: TableColumn<ITEM, ACTION, VIEW>) {
        columns[column.identifier] = column.typeErased()
        let nscolumn = NSTableColumn(identifier: column.identifier)
        nscolumn.headerCell.title = column.title
        column.setupColumn(nscolumn)
        tableView.addTableColumn(nscolumn)
        resetActions()
    }

    open override func loadView() {
        children(
            scrollView
        )

        scrollView.documentView = tableView

        tableView.delegate = self
        tableView.dataSource = self
        tableView.autoresizingMask = [.viewWidthSizable, .viewHeightSizable]
    }

    open override func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    public func numberOfRows(in tableView: NSTableView) -> Int {
        return componentDelegate.hasComponentState ? componentState.count : 0
    }

    public func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let tableColumn = tableColumn, let column = columns[tableColumn.identifier] else { return nil }
        let item = componentState[row]
        let view = tableView.make(withIdentifier: column.identifier, owner: self) ?? column.makeView()
        column.setComponentState(item, view)
        return view
    }

    public func tableViewSelectionDidChange(_ notification: Notification) {
        let selectedIndex = tableView.selectedRow
        guard componentState.indices ~= selectedIndex else { return }
        let item = componentState[selectedIndex]
        perform(action: .selected(item))
    }
}
