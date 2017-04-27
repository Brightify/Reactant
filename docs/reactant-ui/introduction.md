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
pushd $PROJECT_DIR
env -i HOME=$HOME PATH=$PATH swift build
popd

pushd $PROJECT_DIR/Example
$PROJECT_DIR/.build/debug/reactant-ui > $PROJECT_DIR/Example/Generated/GeneratedUI.swift
popd
```
