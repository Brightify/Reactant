# TableView

In Reactant, using table views is simple. There are TableView classes prepared for drop-in use, suiting most of the use cases. The TableViews are Components so they have their `componentState` and actions depending on the type of TableView.

Every TableView's component State is a `TableViewState` which is an enum containing these cases:
```swift
public enum TableViewState<MODEL> {
    case items([MODEL])
    case empty(message: String)
    case loading
}
```

In `init` of every TableView, you can configure if the TableView is reloadable and other properties depending on TableView type.

#### SimpleTableView
 `SimpleTableView` is the most generic TableView of them all. Its purpose is to display table with footers and headers. It has three generic parameters: `HEADER` - View component used as headers, `CELL` View component used as cells, `FOOTER` view component used as footers. `MODEL` parameter in this case is a `SectionModel` which binds together component State of section header, array of component States of cells and component State of section footer.

#### PlainTableView
 `PlainTableView` is used for displaying plain table view consisting of cells only. `MODEL` parameter of this TableView's `TableViewState` is component State of the cell.

 Example of using this type of TableView directly as RootView is shown here.
 ```swift
 class TableViewRootView: PlainTableView<LabelView>, RootView {

    override var edgesForExtendedLayout: UIRectEdge {
        return .all
    }

    init() {
        super.init(cellFactory: LabelView.init,
                   style: .plain,
                   reloadable: false)
    }
}
```

#### HeaderTableView and FooterTableView
These two TableViews show sections with headers only or footers only.

#### SimulatedSeparatorTableView
This TableView is used for displaying TableView with separators of bigger height than default.
