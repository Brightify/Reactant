# Reactant UI

## Important Note
Reactant UI is currently a preview. However we'll try to keep the number of API changes to a minimum.

## What is Reactant UI
**Reactant UI** is an extension for **Reactant** allowing you to declare views and layout using XML. Don't worry, there's no runtime overhead, as all those declarations are precompiled into Swift. Reactant then uses the generated code to create your UI.

## Why

When we created Reactant, our primary goal was maximal compile-time safety. We devised an API for writing [views using Reactant](../getting-started/quickstart.md), but it was still constrained by Swift's syntax.

## Installation

Reactant UI is available through [CocoaPods](http://cocoapods.org). To install it, add the following line to your application target in your Podfile:

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
