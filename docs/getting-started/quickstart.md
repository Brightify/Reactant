# Quick-start guide

Reactant is available through [CocoaPods](http://cocoapods.org). To install it, add the following line to your application target in your Podfile:

```ruby
pod 'Reactant'
```

This will integrate reactant into your project and you're good to go.

## Writing components

**Components** are an integral part of Reactant so let's learn more about them.

### What's a component

It's part of your application with a single mutation point. That point is `componentState`. Each time you mutate `componentState` property, Reactant will automatically call `update()` method on the **Component**. In this method, **Component** should set itself up according to the state. Let's see how that works. In the example below, we have a **Component** that has `componentState` of type `String` that's supposed to be a name. Our `GreeterComponent` will print a greeting to console.

**NOTE**: Don't worry about the second generic parameter, for now, we'll cover it later on.

```swift
final class GreeterComponent: ComponentBase<String, Void> {
    override func update() {
        print("Hello \(componentState)!")
    }
}

let greeter = GreeterComponent() // nothing printed yet, waiting for componentState
greeter.componentState = "John" // prints "Hello John!"
greeter.componentState = "World" // prints "Hello World!"
```

As you can see, when we changed the `componentState`, the `update()` got called and it printed the greeting. This **Component** doesn't do much, but it's enough to illustrate the relation between `componentState` and `update()`.

Remember that the type of `componentState` should always be a value type. If you use a class type, mutating its properties won't run `update()` and you would have to call `invalidate()` yourself for each change.

### View as a Component

Let's now take a look at how we can use it with *UIKit*. In the following example, our `GreeterComponent` is now `GreeterView` and it extends class `ViewBase` which is a `UIView`.

```swift
final class GreeterView: ViewBase<String, Void> {
    private let greeting = UILabel()

    override func update() {
        greeting.text = "Hello \(componentState)!"
    }

    override func loadView() {
        children(
            greeting
        )

        greeting.textColor = .red
    }

    override func setupConstraints() {
        greeting.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
```

As you can see, it got more interesting. Instead of printing to console, we set the `text` on a label. Notice that we don't set the `textColor` in `update()` as it's not dependent on the `componentState`. You can work with instances of `GreeterView` as with any other `UIView`. But since it has a single point of mutation, you can reuse it and always be sure it gets the input it needs to display properly.

We'll talk about `loadView()` and `setupConstraints()` methods later on.

### Component Action

When a **Component** needs to notify it's owner, it produces an **Action**. Remember the second generic parameter from earlier? That specifies the type of produced **Action**. The type can be anything, but we recommend using *enum*s. We leverage **RxSwift**'s *Observables* for actions since they are versatile and easier to use than callbacks or delegates. Let's extend our `GreeterView` with a text field.

```swift
import RxSwift

enum GreeterAction {
    case greetingChanged(String)
}

final class GreeterView: ViewBase<String, GreeterAction> {
    override var actions: [Observable<GreeterAction>] {
        return [
            nameField.action.map(GreeterAction.greetingChanged)
        ]
    }

    private let greeting = UILabel()
    private let nameField = TextField()

    override func update() {
        greeting.text = "Hello \(componentState)!"
        nameField.componentState = componentState
    }

    override func loadView() {
        children(
            greeting,
            nameField
        )

        greeting.textColor = .red
    }

    override func setupConstraints() {
        greeting.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
        }

        nameField.snp.makeConstraints { make in
            make.top.equalTo(greeting.snp.bottom).offset(10)
            make.left.bottom.right.equalToSuperview()
            make.height.equalTo(50)
        }
    }
}

let greeterView = GreeterView()
greeterView.action.subscribe(onNext: greeterView.setComponentState)
```

Now add the `greeterView` to your view hierarchy and write into the text field. Everything you'll type into the field will change the `componentState` and get shown by the label.

When you integrate Reactant architecture to your application, you won't need to subscribe to the action manually. Instead, you will propagate all actions to a **Controller** which will process and react accordingly.

Learn more about the architecture on the [next page](./architecture.md).

### Optional parts

Reactant also has optional subspecs that you can use so that you won't need to write some often used boilerplate. We'll continue to add more common and useful abstractions.

#### [TableView](../parts/tableview.md)
```ruby
pod 'Reactant/TableView'
```

#### [CollectionView](../parts/collectionview.md)
```ruby
pod 'Reactant/CollectionView'
```

#### [Validation](../parts/validation.md)
```ruby
pod 'Reactant/Validation'
```

#### [ActivityIndicator](../parts/activityindicator.md)
```ruby
pod 'Reactant/ActivityIndicator'
```

#### [StaticMap](../parts/staticmap.md)
```ruby
pod 'Reactant/StaticMap'
```
