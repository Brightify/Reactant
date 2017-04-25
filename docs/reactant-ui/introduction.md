# Reactant UI

## Important Note
Reactant UI is currently a preview. However we'll try to keep the number of API changes to a minimum.

## What is Reactant UI
**Reactant UI** is an extension for **Reactant** allowing you to declare views and layout using XML. Don't worry, there's no runtime overhead, as all those declarations are precompiled into Swift. Reactant then uses the generated code to create your UI.

## Why

When we created Reactant, our primary goal was maximal compile-time safety. We devised an API for writing [views using Reactant](../getting-started/quickstart.md), but it was still constrained by Swift's syntax.

## Installation

Reactant UI is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your test target in your Podfile:

```ruby
pod 'Reactant'
```
