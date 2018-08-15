---
id: wireframe
title: Wireframe
sidebar_label: Wireframe
---
In Reactant, Wireframe is meant to handle transitions between controllers, so that no controller knows about any other controllers. To learn more, head over to our [Reactant Architecture Guide](getting-started/architecture.md).

To make this a little easier we include a protocol `Wireframe` with two helper methods:

## `create(factory:)`

Use create to get access to enclosing `UINavigationController` and the created controller in reaction closures you provide the controller. This lets you break the dependency cycle.

The `create` method has following signature:

```swift
public func create<T>(factory: (FutureControllerProvider<T>) -> T) -> T
```

And you would use it like so:

```swift
class MainWireframe: Wireframe {
    func controller1() -> Controller1 {
        return create { provider in
            let reactions = Controller1.Reactions(
                openController2: {
                    provider.navigation?.push(self.controller2())
                }
            )
            return Controller1(reactions: reactions)
        }
    }

    func controller2() -> Controller2 {
        return create { _ in
            return Controller1()
        }
    }
}
```


## `branchNavigation(controller:)`

Navigation branching is especially useful when you need to present a controller modally and want to display a navigation bar (with the possibility to dismiss the controller). When that happens, you can use the `branchNavigation` to wrap your controller inside `UINavigationController`. It will also set `leftBarButtonItem` for you that will dismiss the modal controller.

```swift
public func branchNavigation(controller: UIViewController, closeButtonTitle: String?) -> UINavigationController

public func branchNavigation<S, T>(controller: ControllerBase<S, T>) -> UINavigationController
```
