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

## Usage
Reactant is extremely easy to use once you get to know the way it works and then it can save you thousands of lines of code.

Reactant's core principle is that everything is a `Component` and such component has a `state` and an `actions`. The component itself is supposed to update itself based on the state and inform parent component about it's change using an action.

Let's have a look at a simple component that is a view and has a label containing some text in it.



## Author

Tadeas Kriz, tadeas@brightify.org

Filip Dolnik, filip@brightify.org

Matous Hybl, matous@brightify.org

## License

Reactant is available under the MIT license. See the LICENSE file for more info.
