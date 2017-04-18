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

## Features
* [Architecture](architecture.html)
* [Component](component.html)
* [Controller](controller.html)
* [RootView](rootview.html)
* [Wireframe](wireframe.html)
* [TableView](tableview.html)
* [CollectionView](collectionview.html)
* [Validation](validation.html)
* [ActivityIndicator](activityindicator.html)
* [Properties](properties.html)
* [StaticMap](staticmap.html)

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
