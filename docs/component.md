Components
==========

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
