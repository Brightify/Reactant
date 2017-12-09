# Changelog

## 1.1.0
* Add FallbackSafeAreaInsets subspec with a basic implementation of a `safeAreaInsets` and `safeAreaLayoutGuide` fallback for iOS 10.

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
