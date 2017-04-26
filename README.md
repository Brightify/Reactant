# Reactant

[![CI Status](http://img.shields.io/travis/Brightify/Reactant.svg?style=flat)](https://travis-ci.org/Brightify/Reactant)
[![Version](https://img.shields.io/cocoapods/v/Reactant.svg?style=flat)](http://cocoapods.org/pods/Reactant)
[![License](https://img.shields.io/cocoapods/l/Reactant.svg?style=flat)](http://cocoapods.org/pods/Reactant)
[![Platform](https://img.shields.io/cocoapods/p/Reactant.svg?style=flat)](http://cocoapods.org/pods/Reactant)
[![Apps](https://img.shields.io/cocoapods/at/Reactant.svg?style=flat)](http://cocoapods.org/pods/Reactant)
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
it, simply add the following line to your test target in your Podfile:

```ruby
pod 'Reactant'
# these subspecs are optional, but recommended
pod 'Reactant/TableView'
pod 'Reactant/CollectionView'
pod 'Reactant/Validation'
```

## Versioning

This library uses semantic versioning. Until the version 1.0 API breaking changes may occur even in minor versions. We consider the version 0.6 to be prerelease, which means that API should be stable but is not tested yet in a real project. After that testing, we make needed adjustments and bump the version to 1.0 (first release).

## Author

* Tadeas Kriz, [tadeas@brightify.org](mailto:tadeas@brightify.org)
* Matous Hybl, [matous@brightify.org](mailto:matous@brightify.org)
* Filip Dolník, [filip@brightify.org](mailto:filip@brightify.org)

## Used libraries

* [Result](https://github.com/antitypical/Result)
* [SnapKit](https://github.com/SnapKit/SnapKit)
* [RxSwift](https://github.com/ReactiveX/RxSwift)
* [RxCocoa](https://github.com/ReactiveX/RxSwift)
* [RxOptional](https://github.com/RxSwiftCommunity/RxOptional)
* [RxDataSources](https://github.com/RxSwiftCommunity/RxDataSources)

### Tests

* [Quick](https://github.com/Quick/Quick)
* [Nimble](https://github.com/Quick/Nimble)
