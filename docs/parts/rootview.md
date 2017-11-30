# RootView

As forementioned in the [Reactant architecture guide](../getting-started/architecture.md), `RootView` is a protocol and a marker for views that should be the root of a screen (filling the whole screen). Apart from being a marker, it's also used for communication with its parent controller.

## edgesForExtendedLayout

This property is very similar to `UIViewController#edgesForExtendedLayout`. It specifies whether the view should be positioned behind translucent bars like the `UINavigationBar` and `UITabBar`. If you set `.all` (or `.top` / `.bottom`), the parent controller will make sure the view is under those bars. This is often used for root views that contain scroll views or tables.

The default value is `[]` (or none), meaning that the root view will not be extended under those bars and thus no part of the view will be obstructed.

## viewWillAppear()
Called by the parent Controller when the screen will appear.

For more information take a look at [`UIViewController#viewWillAppear`](https://developer.apple.com/reference/uikit/uiviewcontroller/1621510-viewwillappear)

## viewDidAppear()
Called by the parent Controller when the screen did appear.

For more information take a look at [`UIViewController#viewDidAppear`](https://developer.apple.com/reference/uikit/uiviewcontroller/1621423-viewdidappear)

## viewWillDisappear()
Called by the parent Controller when the screen will disappear.

For more information take a look at [`UIViewController#viewWillDisappear`](https://developer.apple.com/reference/uikit/uiviewcontroller/1621485-viewwilldisappear)

## viewDidDisappear()
Called by the parent Controller when the screen did disappear.

For more information take a look at [`UIViewController#viewDidDisappear`](https://developer.apple.com/reference/uikit/uiviewcontroller/1621477-viewdiddisappear)
