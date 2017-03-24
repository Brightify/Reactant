# Reactant

[![CI Status](http://img.shields.io/travis/Brightify/Reactant.svg?style=flat)](https://travis-ci.org/Brightify/Reactant)
[![Version](https://img.shields.io/cocoapods/v/Reactant.svg?style=flat)](http://cocoapods.org/pods/Reactant)
[![License](https://img.shields.io/cocoapods/l/Reactant.svg?style=flat)](http://cocoapods.org/pods/Reactant)
[![Platform](https://img.shields.io/cocoapods/p/Reactant.svg?style=flat)](http://cocoapods.org/pods/Reactant)
[![Slack Status](http://swiftkit.brightify.org/badge.svg)](http://swiftkit.brightify.org)

Reactant is a framework and architecture for developing iOS apps quickly without writing code all over again. It is based on ReactiveX and originally was inspired by React Native.

## Requirements

* iOS 8.0+ (macOS is support is experimental, watchOS most likely won't be supported, tvOS was not tested)
* Xcode 8.0+
* Swift 3.0+

## Communication
Feel free to reach us on Slack! http://swiftkit.brightify.org/

## Installation

Reactant is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Reactant'
# these subspecs are optional, but recommended
pod 'Reactant/TableView'
pod 'Reactant/CollectionView'
pod 'Reactant/Validation'
```

## Usage
Reactant is extremely easy to use once you get to know the way it works and then it can save you thousands of lines of code.

Reactant's core principle is that everything is a `Component` and such component has a `state` and an `actions`. The component itself is supposed to update itself based on the state and inform parent component about it's change using an action.

Let's have a look at a simple component that is a view and has a label containing some text in it.
```swift
final class LabelView: ViewBase<String, Void> {

    private let label = UILabel()

    override func update() {
        label.text = componentState
    }

    override func loadView() {
        children(
            label
        )

        label.backgroundColor = .black
    }

    override func setupConstraints() {
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
```
As you can see all `UIView` components inherit from `ViewBase` (there is a special class `ButtonBase` for buttons with view structure inside). The `ViewBase` has two generic parameters, first one is `StateType` which determines type of this component's state, in this case it is a `String`, since we only want to display a text in a label, and second one is `ActionType` that determines type of an action this view produces, this example has no action, so the specified type is `Void` (more on actions will be explained later). We strongly recommend that the `StateType` is value type, because whenever it changes, the `Component` will call `update` method, this way if the `StateType` is a `struct` or `tuple`, whenever you update any field of these types, the `Component` will update its contents.

Method `update` is responsible for updating your `Component`'s views etc. In this case it sets `componentState` which is a `String` to the `label`'s text.

In `loadView` the views are added to view hierarchy using `children` method. This method is an extension of UIView and it is possible to nest children calls. Like this:
```swift
children(
    label1.children(
        label2,
        label3
        ),
    label4
)
```

Method `setupConstraints` is responsible for layouting. Reactant uses SnapKit to do this, but other layouting engines (such as `NSLayoutAnchor`) should work.

### Controllers and RootViews
Even controllers are `Components` in Reactant. Reactant was designed in a way that controller should never interact directly with any views it contains. Its only purpose is to somehow obtain state (from API, database etc.) and set this state to its `RootView` that takes care of displaying data. RootView is also responsible for notifying the controller about actions and the controller should respond to them accordingly i.e. by sending data to API, updating database etc.

Let's say that we have `MainController` and `MainRootView`.
```swift
final class MainViewController: ControllerBase<Void, MainRootView> {

    init() {
        // this needs to be called like this, because of a bug in Swift
        super.init(title: "Main")

        // set inital state of RootView
        rootView.componentState = Date()
    }

    override func update() {
        // do nothing since this controller has void state
    }

    // Act according to action from RootView
    override func act(on action: MainRootView.ActionType) {
        switch action {
        case .updateLabel:
            // when this action is sent from RootView, set new state to RootView's componentState
            rootView.componentState = Date()
            break
        // just a dummy action
        case .openTable:
            break
        }
    }
}

enum MainAction {
    case updateLabel
    case openTable
}

final class MainRootView: ViewBase<Date, MainAction>, RootView {

    // this property gather's producers of all actions that should be propagated to parent component
    override var actions: [Observable<MainAction>] {
        return [
            updateButton.rx.tap.rewrite(with: .updateLabel)
        ]
    }

    private let label = LabelView()
    private let updateButton = UIButton()

    private let dateFormatter = DateFormatter()

    override init() {
        super.init()

        dateFormatter.timeStyle = .long
    }

    override func update() {
        label.componentState = dateFormatter.string(from: componentState)
    }

    override func loadView() {
        children(
            label,
            updateButton
        )

        updateButton.setTitleColor(.white, for: .normal)
        updateButton.setTitle("Update", for: .normal)
        updateButton.backgroundColor = .blue
    }

    override func setupConstraints() {
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        updateButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview().offset(20)
            make.trailing.lessThanOrEqualToSuperview().inset(20)

            make.top.equalTo(label.snp.bottom).offset(20)
        }
    }
}
```

In this case RootView is responsible for displaying `Date` in a label. It also has a button, which whenever user clicks, invokes it's `rx.tap` event and this event is propagated to controller using `actions` property. Controller react's to such event using method `act`, so whenever `.updateLabel` value is passed to this method, new `Date` is set to RootView's `componentState`.

`ActionType` of RootView is in this case an `enum` `MainAction`. But it can be any other data type. Important advantage of using enums is that you can relatively easily add more action types, pass parameters to these actions and even **nest** enum values, which is very handy when propagating actions using `action` field of nested view.

### Wireframe
Wireframe is our way of handling navigation in the whole app as well as dependency management. Controllers have Dependencies and Reactions, which are closures or `Observables` they use to pass data to other controllers and/or open them.

Let's have a look at `MainViewController` from previous example, now with Wireframe support.
```swift
final class MainViewController: ControllerBase<Void, MainRootView> {

    // Define Reactions
    struct Reactions {
        let openTable: () -> Void
    }

    private let reactions: Reactions

    init(reactions: Reactions) {
        self.reactions = reactions
        // this needs to be called like this, because of a bug in Swift
        super.init(title: "Main")

        // set inital state of RootView
        rootView.componentState = Date()
    }

    override func update() {
        // do nothing since this controller has void state
    }

    // Act according to action from RootView
    override func act(on action: MainRootView.ActionType) {
        switch action {
        case .updateLabel:
            // when this action is sent from RootView, set new state to RootView's componentState
            rootView.componentState = Date()
            break
        case .openTable:
            // when this action is sent from RootView, call function openTable defined in reactions
            reactions.openTable()
            break
        }
    }
}
```
As you can see, it has only `Reactions` which define a closure that should be called when table is to be opened. The controller that should be opened when this closure is invoked is `TableViewController`.
```swift
class TableViewController: ControllerBase<Void, TableViewRootView> {

    struct Dependencies {
        let nameService: NameService
    }

    struct Reactions {
        let displayName: (String) -> Void
    }

    private let dependencies: Dependencies
    private let reactions: Reactions

    init(dependencies: Dependencies, reactions: Reactions) {
        self.dependencies = dependencies
        self.reactions = reactions
        super.init()
    }

    override func update() {
        rootView.componentState = .items(dependencies.nameService.names())
    }

    override func act(on action: TableViewRootView.ActionType) {
        switch action {
        case .selected(let name):
            reactions.displayName(name)
        default:
            break
        }
    }
}
```

As you can see, it has both `Dependencies` and `Reactions`. In this case `Dependencies` contains service responsible for getting a list of names and is used in `update` method. `Reactions` are used to open `UIAlertController` when an item is selected.

Now we have all the prerequisities, so let's have a look at what ties all of the controllers together - the Wireframe itself.
```swift
class MainWireframe: Wireframe {

    private let dependencyModule: DependencyModule

    init(dependencyModule: DependencyModule) {
        self.dependencyModule = dependencyModule
    }

    func entrypoint() -> UIViewController {
        return UINavigationController(rootViewController: mainController())
    }

    private func mainController() -> UIViewController {
        return create { provider in
            let reactions = MainViewController.Reactions(openTable: {
                provider.navigation?.push(controller: self.tableViewController())
            })

            return MainViewController(reactions: reactions)
        }
    }

    private func tableViewController() -> UIViewController {
        return create { provider in
            let dependencies = TableViewController.Dependencies(nameService: dependencyModule.nameService)
            let reactions = TableViewController.Reactions(displayName: { name in
                provider.navigation?.present(controller: self.nameAlertController(name: name))
            })
            return TableViewController(dependencies: dependencies, reactions: reactions)
        }
    }

    private func nameAlertController(name: String) -> UIViewController {
        let controller = UIAlertController(title: "This is a name", message: name, preferredStyle: .actionSheet)
        controller.addAction(UIAlertAction(title: "Close", style: .cancel, handler: { _ in controller.dismiss() }))
        return controller
    }
}
```
This wireframe has one init parameter - DependencyModule which is responsible for creating dependencies for controllers. Each of the wireframe's method is responsible for creating controllers, their Reactions and Dependencies. Important method is entrypoint that is called in `AppDelegate` and its result is assigned to application window. Method `create` is used to simplify working with navigation as its parameter `provider` has field `navigationController: UINavigationController`. 
Another important method, that is however not used in this sample is `branchNavigation` that creates new `UINavigationController` which can have a close button and then it can be used as a modal controller.

Wireframe is then used in `AppDelegate` like this:
```swift
        let module = AppModule()

        let wireframe = MainWireframe(dependencyModule: module)

        window?.rootViewController = wireframe.entrypoint()
```

### TableView
In Reactant, using table views is extremely simple. There are TableView classes prepared for drop-in use suiting most of the use cases. The TableViews are Components so they have their component State and actions depending on the type of TableView.

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
These two TableViews are TableViews that show sections with headers only or footers only.

#### SimulatedSeparatorTableView
This TableView is used for displaying TableView with separators of bigger height than default are.

### Validation
Validation classes can be used for extremely easy validation of for example user inputs such as emails or passwords.

A good example of creating Rules for validation is in `StringRules` class. Let's have a look at `minLenghtRule`.

```swift
public static func minLength(_ length: Int) -> Rule<String?, ValidationError> {
        return Rule { value in
            guard let value = value, value.characters.count >= length else {
                return .invalid
            }
            return nil
        }
    }
```

If the condition for valid string is not true, then this code returns `ValidationError.invalid`, otherwise returns `nil`.

Usage of this rule is simple and can look like this when being used as a part of `Observable` stream.
```swift
Observable.from(["this", "is", "a", "message"])
            .map { StringRules.minLength(4).run($0) }
            .filterError()
            .subscribe(onNext: { print($0 ?? "") })
            .addDisposableTo(stateDisposeBag)
```

This code prints only `this` `message` - the strings that are valid.

## Author

Tadeas Kriz, tadeas@brightify.org

Filip Dolnik, filip@brightify.org

Matous Hybl, matous@brightify.org

## License

Reactant is available under the MIT license. See the LICENSE file for more info.
