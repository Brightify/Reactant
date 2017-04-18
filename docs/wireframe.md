Wireframe
=========

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
