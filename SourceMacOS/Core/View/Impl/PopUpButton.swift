import Cocoa

open class PopUpButton<ITEM>: ViewBase<ITEM, ITEM> {
    public let button = NSPopUpButton()

    private let items: [ITEM]
    private let itemsEqual: (ITEM, ITEM) -> Bool

    public init(items: [ITEM], itemTitle: (ITEM) -> String, itemsEqual: @escaping (ITEM, ITEM) -> Bool) {
        self.items = items
        self.itemsEqual = itemsEqual

        super.init()

        button.addItems(withTitles: items.map(itemTitle))
    }

    open override func update() {
        let state = componentState
        if let index = items.index(where: { itemsEqual(state, $0) }) {
            button.selectItem(at: index)
        }
    }

    open override func loadView() {
        children(
            button
        )
        button.target = self
        button.action = #selector(itemSelected(_:))
    }

    open override func setupConstraints() {
        button.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    internal func itemSelected(_ item: NSMenuItem) {
        perform(action: items[button.indexOfSelectedItem])
    }
}

extension PopUpButton where ITEM: Equatable {
    public convenience init(items: [ITEM], itemTitle: (ITEM) -> String) {
        self.init(items: items, itemTitle: itemTitle, itemsEqual: ==)
    }
}
