# Changelog

## 1.2.0
* Add takeUntil to Wireframe
* Add option to disable automatic cell deselection
* Add ActivityIndicator to subspec groups
* Add reference for create<U,T>() and rewrite()
* Deprecate ButtonBase with ControlBase
* Add system font support
* Update project for Swift 4.1
* Add generic PickerView
* Add method for stacking UIViews inside UIView
* Fix `rotate` in CGAffineTransformation extensions
* Add `dequeueAndConfigure(identifier:indexPath:factory:model:mapAction:)` to `CollectionView`
* Add better initial configuration of `TableView` and `CollectionView`
* Add styling methods for `UINavigationController` and `UITabBarController`
* Remove RxSwift and SnapKit dependencies from `Configuration` subspec

## 1.1.0
* Add FallbackSafeAreaInsets subspec with a basic implementation of a `safeAreaInsets` and `safeAreaLayoutGuide` fallback for iOS 10.
* Add support for tvOS
* Add reference guide
* Add more docs
* Add tutorials
* Add more tests

## 1.0.6
* Fix TableViewBase and CollectionViewBase memory leak.

## 1.0.5
* Add create to Wireframe with controller result helper
* Add default implementation to DialogDismissalController
* Add option to have present dialog with result in UINavigationController
* Add styling for DialogControllerBase's `view`
* Possibly breaking: changed `bind(items: [MODEL])` to `bind(items: Observable<[MODEL]>)` in both `TableViewBase` and `CollectionViewBase`. This change was made because RxSwift changed the internals of delegates and dataSources and each `update` caused the TableView/CollectionView to scroll to the beginning.

## 1.0.4
* Improved documentation

## 1.0.3
* Fixed `TextField` where placeholder didn't have correct position

## 1.0.2
* Added `setBackgroundColor:forState` objc alias for ReactantUI

## 1.0.1
* Fixed Reactant Example project

## 0.6.0

* Complete API redesign
* Added tests
* Added documentation
* Added changelog
