---
id: introduction
title: Introduction
sidebar_label: Introduction
---
## Important Note
Reactant UI is currently a preview. However we'll try to keep the number of API changes to a minimum.

## What is Reactant UI
**Reactant UI** is an extension of **Reactant** allowing you to declare views and layout using XML. Don't worry, there's no runtime overhead as all those declarations are precompiled into Swift. Reactant then uses the generated code to create your UI.

## Why
When we created Reactant, our primary goal was maximal compile-time safety. We devised an API for writing [views using Reactant](getting-started/quickstart.md), but it was still constrained by Swift's syntax.

## Installation
Reactant UI is available through [CocoaPods](http://cocoapods.org). To install it, add the following line to your application target in your `Podfile`:

```ruby
pod 'ReactantUI'
```

This will add Reactant UI source files to your project. After that open your Xcode project, go to *Build Phases*, and create a new *Run Script* phase (`+` button in top left corner -> `New Run Script Phase`).

Give the new phase a name (e.g. *"Generate Reactant UI"*) and move it just above phase called `Compile Sources (n items)`.

Last step is putting the following shell script into the newly created phase:

```sh
pushd "$PODS_ROOT/ReactantUI"
env -i HOME="$HOME" PATH="$PATH" swift build
popd
# Run reactant-ui generator and save the output to a single `.swift` file
"$PODS_ROOT/ReactantUI/.build/debug/reactant-ui" generate --inputPath="$PROJECT_DIR/Application/" --outputFile="$SRCROOT/Application/Generated/GeneratedUI.swift" --xcodeprojPath=$PROJECT_DIR/ReactantUI.xcodeproj
```

## Recommended editor

We recommend downloading [**Atom**](https://atom.io/) editor and installing [**linter-autocomplete-jing**](https://atom.io/packages/linter-autocomplete-jing) and [**xml-common-schemata** ](https://atom.io/packages/xml-common-schemata) plugins. This combination will give you auto-complete support for Reactant's UI XML files.

## UI XML

Reactant UI loads view declarations from XML files ending with `.ui.xml`. The location of these files is up to you, although we recommend putting them alongside your `.swift` view files for better file navigation. In [Reactant Architecture Guide](getting-started/architecture.md) we create a very simple, single-screen application with one input and one textfield. Let's recreate the `GreeterRootView` using Reactant UI.

We begin with creating a new file named `GreeterRootView.ui.xml`, adding a root element called `Component` and setting namespace attributes to enable autocompletion.

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<Component
    xmlns="http://schema.reactant.tech/ui"
    xmlns:layout="http://schema.reactant.tech/layout"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://schema.reactant.tech/ui http://schema.reactant.tech/ui.xsd
                        http://schema.reactant.tech/layout http://schema.reactant.tech/layout.xsd">
</Component>
```

**NOTE**: Once we release Reactant UI beta, we will freeze schema definitions and release plugin for Atom that will allow omission of `xmlns:xsi` and `xsi:schemaLocation` attributes. This will result in simpler declarations.

By default, the name of the file is used as the type name. However, you can override this behavior. To do so, add `type` attribute to the `Component` element with the name of your desired type.

You might want to create all `.ui.xml` at once before writing their Swift counterparts (especially if you use [Live Reload](reactant-ui/live-reload.md)). Unfortunately, Reactant UI in its current version doesn't scan your Swift files for existing types and generates Swift extensions for every `.ui.xml` in your project. If you don't have matching classes, you'll get compile errors. The current workaround is setting a value of `anonymous` attribute to `true` on the `Component` element. Reactant UI then generates an empty class which you can then use in your code. Later on you would replace it with your own class and remove the `anonymous` attribute.

Last `Component` attribute to keep an eye on is `rootView`. Setting it to `true` automatically adds the `RootView` protocol conformity which allows you to specify `extend` attribute. This attribute sets the RootView's `edgesForExtendedLayout` which has similar behavior to [`UIViewController#edgesForExtendedLayout`](https://developer.apple.com/reference/uikit/uiviewcontroller/1621515-edgesforextendedlayout).

Let's go ahead and add the two children our `GreeterRootView` should have, a label and a text field.

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<Component
    xmlns="http://schema.reactant.tech/ui"
    xmlns:layout="http://schema.reactant.tech/layout"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://schema.reactant.tech/ui http://schema.reactant.tech/ui.xsd
                        http://schema.reactant.tech/layout http://schema.reactant.tech/layout.xsd"
    rootView="true">

    <Label
        text="Hello World"
        textColor="red"
        field="greeting"
        layout:left="super"
        layout:top="super"
        layout:right="super" />

    <TextField
        placeholder="Name to greet"
        field="nameField"
        layout:left="super"
        layout:right="super"
        layout:below="greeting offset(10)"
        layout:bottom="super"
        layout:height="50" />
</Component>
```

Each view in the hierarchy has its own properties and we tried to keep same names they have in UIKit. In our example, we set the `text` attribute for `Label` element to setup a label with that text. The same applies to the `textColor` and `placeholder` attributes.

When you need to create a connection between your Swift code and the UI XML, set the `field` attribute. This attribute tells Reactant UI to use field with the specified name in the view. Make sure that field (property) has an internal visibility and that the type matches. We also recommend that the field is a constant (`let` property) because it limits mutability even further.

Last but not least, `layout` attributes. They are used to declare AutoLayout constraints for your views. Each attribute from the `layout` namespace accepts a constraint declaration with the following format:

`[constraintField = ][>=|<=|==] target[.targetAnchor] [modifier...][ @priority]`

Parts of the declaration should be familiar to you if you use AutoLayout.

* **constraintField** - makes the created constraint accessible in your Swift code (e.g. )
* **\>=|<=|==** - relation of the constraint
* **target** - The other view to constraint to. Possible values are:
    * `id:{name}` - target a view using `layout:id` attribute of such view
    * `{name}` - target a view using `field` attribute of such view
    * `super` - parent container (equal to `UIView#superview`)
    * `self` - this view, mostly useful for constraining width and height
* **targetAnchor** - an anchor on the target view to constraint to. Defaults
* **modifier**
    * Supported modifiers
        * `offset(value)` - constant space between two views
        * `inset(value)` - constant space between parent and its child view (inside)
        * `multiplied(by: value)` - multiplier for the constraint
        * `divided(by: value)` - same function as a multiplier, but using it as 1/value
    * `value` is any Float number
* **priority**
    * one of `required`, `high`, `medium`, `low`
    * any float ranging from 1 to 1000

To complete the example we need to write the Swift part of the `GreeterRootView`. We basically just remove the `loadView` and `setupConstraints` methods, make the `greeting` and `nameField` properties `internal` and remove the `RootView` protocol conformance. And this is what we'll get:

```swift
import Reactant

final class GreeterRootView: ViewBase<(greeting: String, name: String), GreeterAction> {
    override var actions: [Observable<GreeterAction>] {
        return [
            nameField.action.map(GreeterAction.greetingChanged)
        ]
    }

    let greeting = UILabel()
    let nameField = UITextField()

    override func update() {
        greeting.text = "Hello \(componentState)!"
        nameField.componentState = componentState
    }
}
```

As you can see, when we use the XML to declare views, our Swift code will contain only the code that decides what should be done with `componentState` in the `update()` method and it produces actions for owners to handle. At the same time the XML gives us much cleaner UI code as you can see the view's position in the layout and its properties at one place.

This split to XML also allowed us to implement a live UI reloading. It's something that will save quite a lot of development time as you can see every change in the UI without recompilation and redeployment.

[**Learn more about Reactant UI's Live Reload capabilities**](reactant-ui/live-reload.md)
