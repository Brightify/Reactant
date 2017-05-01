# Reactant UI

## Important Note
Reactant UI is currently a preview. However we'll try to keep the number of API changes to a minimum.

## What is Reactant UI
**Reactant UI** is an extension for **Reactant** allowing you to declare views and layout using XML. Don't worry, there's no runtime overhead, as all those declarations are precompiled into Swift. Reactant then uses the generated code to create your UI.

## Why
When we created Reactant, our primary goal was maximal compile-time safety. We devised an API for writing [views using Reactant](../getting-started/quickstart.md), but it was still constrained by Swift's syntax.

## Installation
Reactant UI is available through [CocoaPods](http://cocoapods.org). To install it, add the following line to your application target in your `Podfile`:

```ruby
pod 'ReactantUI'
```

This will add Reactant UI to your project, but we're not done yet. Open your project in Xcode and open *Build Phases* and create a new *Run Script* phase (`+` button in top left corner -> `New Run Script Phase`). Name the phase (for example `Generate Reactant UI`) and move it just above phase named `Compile Sources (n items)`. Now add the following into the newly created phase.

```sh
pushd "$PODS_ROOT/ReactantUI"
env -i HOME="$HOME" PATH="$PATH" swift build
popd
# Go into directory where you'll have `.ui.xml` files.
cd "$SRCROOT/Application/Source"
# Run reactant-ui generator and save the output to a single `.swift` file
"$PODS_ROOT/ReactantUI/.build/debug/reactant-ui" > "$SRCROOT/Application/Generated/GeneratedUI.swift"
```

## Recommended editor

We recommend you to download [**Atom**](https://atom.io/) editor and install [**linter-autocomplete-jing**](https://atom.io/packages/linter-autocomplete-jing) plugin. This combination will give you auto-complete support for UI XML files.

## UI XML

Reactant UI loads view declarations from XML files ending with `.ui.xml`. The location of these files is up to you, but we recommend putting them alongside your `.swift` view files. In [Reactant architecture guide](../getting-started/architecture.md) we made a very simple, single-screen application with one input and one textfield. Let's now recreate the `GreeterRootView` using Reactant UI.

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

You might want to create all `.ui.xml` at once before writing their Swift counterparts (especially if you use [Live Reload][live-reload]). Unfortunately, Reactant UI in its current version doesn't scan your Swift files for existing types and generates Swift extensions for every `.ui.xml` in your project. If you don't have matching classes, you'll get compile errors. The current workaround is setting a value of `anonymous` attribute to `true` on the `Component` element. Reactant UI then generates an empty class which you can then use in your code. Later on you would replace it with your own class and remove the `anonymous` attribute.

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<Component
    xmlns="http://schema.reactant.tech/ui"
    xmlns:layout="http://schema.reactant.tech/layout"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://schema.reactant.tech/ui http://schema.reactant.tech/ui.xsd
                        http://schema.reactant.tech/layout http://schema.reactant.tech/layout.xsd"
    type="GreeterRootView">
</Component>
```



```xml
<?xml version="1.0" encoding="UTF-8" ?>
<Component
    xmlns="http://schema.reactant.tech/ui"
    xmlns:layout="http://schema.reactant.tech/layout"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://schema.reactant.tech/ui http://schema.reactant.tech/ui.xsd
                        http://schema.reactant.tech/layout http://schema.reactant.tech/layout.xsd"
    type="GreeterRootView"
    rootView="true">

    <Label
        text="Hello World"
        layout:id="greeting"
        layout:left="super"
        layout:top="super"
        layout:right="super" />

    <TextField
        field="nameField"
        layout:left="super"
        layout:right="super"
        layout:below="id:greeting offset(10)"
        layout:bottom="super"
        layout:height="50" />
</Component>
```


```swift
final class GreeterRootView: ViewBase<String, GreeterAction> {
    override var actions: [Observable<GreeterAction>] {
        return [
            // Skipping first event as UITextField.rx.text sends first value
            // when subscribed, but we want later changes
            nameField.rx.text.skip(1).map { GreeterAction.greetingChanged($0 ?? "") }
        ]
    }

    let nameField = UITextField()

    override func update() {
        greeting.text = "Hello \(componentState)!"

        if componentState != nameField.text {
            nameField.text = componentState
        }
    }
}
```

[live-reload]: (./live-reload.md)
