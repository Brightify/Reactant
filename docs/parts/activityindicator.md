# ActivityIndicator

`ActivityIndicator` allows you to track the activity of an `Observable`. It is especially useful when displaying progress of some tasks done by multiple `Observable` in a row because it can monitor all of them and show different associated values based on the current task.

To construct an `ActivityIndicator`, use this init: `init(defaultAssociatedValue: T? = nil)`. Meaning of `defaultAssociatedValue` will be explained in a short while. Type `T` represents type of data associated to `Observable`. If `T` is not `Equatable`, then `init(defaultAssociatedValue: T? = nil, equalWhen equalFunction: @escaping (T, T) -> Bool)` must be used.

To register `Observable` to be tracked by `ActivityIndicator` use:

```swift
extension ActivityIndicator {

	// defaultAssociatedValue from init will be associated to this Observable.
    func trackActivity<O: ObservableConvertibleType>(of source: O)

    // Provided associatedValue will be used instead of the default one.
    func trackActivity<O: ObservableConvertibleType>(of source: O, associatedValue: T?)

    // Associated value will be determined for each value from Observable individually by associatedValueProvider. defaultAssociatedValue will be used as the first associated value.
    func trackActivity<O: ObservableConvertibleType>(of source: O, associatedValueProvider: @escaping (O.E) -> T?)

	// Same as method above, but initialAssociatedValue is provided explicitly.
    func trackActivity<O: ObservableConvertibleType>(of source: O, initialAssociatedValue: T?, associatedValueProvider: @escaping (O.E) -> T?) -> Observable<O.E>
}
```

For example:

```swift
let activityIndicator = ActivityIndicator<String>()
let observable = Observable<Int>.interval(RxTimeInterval(1), scheduler: MainScheduler.instance)
								.take(10)

activityIndicator.trackActivity(of: observable)

observable.subscribe...
```

Usually you do not store `Observable` in a variable (doing so requires to break the chain of function calls). To remove this restriction use these corresponding methods from extension of `ObservableConvertibleType`:

```swift
extension ObservableConvertibleType {

    func trackActivity<T>(in activityIndicator: ActivityIndicator<T>) -> Observable<E>

    func trackActivity<T>(in activityIndicator: ActivityIndicator<T>, associatedValue: T?) -> Observable<E>

    func trackActivity<T>(in activityIndicator: ActivityIndicator<T>, associatedValueProvider: @escaping (E) -> T?) -> Observable<E>

    func trackActivity<T>(in activityIndicator: ActivityIndicator<T>, initialAssociatedValue: T?, associatedValueProvider: @escaping (E) -> T?) -> Observable<E>
}
```

Now we can integrate `ActivityIndicator` to existing `Observable` chain quite nicely:

```swift
let activityIndicator = ActivityIndicator<String>()
let observable = Observable<Int>.interval(RxTimeInterval(1), scheduler: MainScheduler.instance)
								.take(10)
								.trackActivity(in: activityIndicator)
								.subscribe...
```

All of the `trackActivity` methods capture `ActivityIndicator` until the registered `Observable` is disposed, so that you do not have to hold a reference to it.

Example of `associatedValueProvider`:

```swift
let activityIndicator = ActivityIndicator<String>()
activityIndicator.asObservable().subscribe(onNext: {
    print("loading: \($0.loading), associatedValue: \($0.associatedValue ?? "Empty")")
}).disposed(by: activityIndicator.disposeBag)

Observable<Int>.interval(RxTimeInterval(1), scheduler: MainScheduler.instance)
    .trackActivity(in: activityIndicator, initialAssociatedValue: "-1", associatedValueProvider: { "\($0)" })
    .subscribe(onNext: { _ in })
    .disposed(by: lifetimeDisposeBag)
```

Output:

```
loading: false, associatedValue: Empty
loading: true, associatedValue: -1
loading: true, associatedValue: 0
loading: true, associatedValue: 1
...
```

To access data produced by `ActivityIndicator` use `asDriver()` or `asObservable`. For example:

```swift
activityIndicator.asObservable()
				 .subscribe(onNext: {
            			print("loading: \($0.loading), associatedValue: \($0.associatedValue ?? "")")
				 }).disposed(by: activityIndicator.disposeBag)
```

Notice the `activityIndicator.disposeBag`. It is not necessary to add `ActivityIndicator` subscriptions to a `DisposeBag` because they will be released automatically together with the instance of `ActivityIndicator` (so using `activityIndicator.disposeBag` in this case is equivalent to not using any at all). However it is recommended to do so as it will help improve code readability and also without `disposed(by:)` Xcode produces a warning.

`loading` is a `bool` value that tells you if `ActivityIndicator` currently tracks at least one active `Observable` (once `Observable` finishes its work, it is disposed and not considered active). `associatedValue` is `T?` associated with the first active `Observable` (the order of multiple `Observable` sequences is determined by the order they were registered to `ActivityIndicator`). If `loading` is `false`, then `associatedValue` is set to `nil`.

`onNext` is called only when there is a change either in `loading` or `associatedValue`.

Advanced example:

```swift
let activityIndicator = ActivityIndicator<Int>()
activityIndicator.asObservable()
				 .subscribe(onNext: {
    					print("loading: \($0.loading), associatedValue: \($0.associatedValue ?? -1)")	// If associatedValue is nil, print -1 instead.
				 }).disposed(by: activityIndicator.disposeBag)

// Function that creates some Observable emulating long operation (fetching data from disk, etc.).
func createObservable(value: Int, delay: Int) -> Observable<Int> {
    return Observable<Int>.just(value).delay(RxTimeInterval(delay), scheduler: MainScheduler.instance)
}

// Represents serial sequence of three Observables, each takes two seconds to compute. The trackActivity is called immediately so the priority of Observables is: 1, 2, 3, 10, 11 regardless of when they actually start doing something.
createObservable(value: 1, delay: 2)
    .trackActivity(in: activityIndicator, associatedValue: 1)
    .flatMap { value -> Observable<Int> in
        print("Done: \(value)")
        return createObservable(value: 2, delay: 2)
    }.trackActivity(in: activityIndicator, associatedValue: 2)
    .flatMap { value -> Observable<Int> in
        print("Done: \(value)")
        return createObservable(value: 3, delay: 2)
    }.trackActivity(in: activityIndicator, associatedValue: 3)
    .subscribe(onNext: { print("Done: \($0)") })
    .disposed(by: ...)

// ActivityIndicator can track multiple Observables in parallel.
createObservable(value: 10, delay: 3)
    .trackActivity(in: activityIndicator, associatedValue: 10)
    .flatMap { value -> Observable<Int> in
        print("Done: \(value)")
        return createObservable(value: 11, delay: 5)
    }.trackActivity(in: activityIndicator, associatedValue: 11)
    .subscribe(onNext: { print("Done: \($0)") })
    .disposed(by: ...)
```

The output of this code is:
```
loading: false, associatedValue: -1
loading: true, associatedValue: 1
Done: 1
loading: true, associatedValue: 2 		// Observable 2 is registered before 10.
Done: 10						        // Observable 10 finishes before 2 but that doesn't change the associatedValue.
Done: 2
loading: true, associatedValue: 3
Done: 3
loading: true, associatedValue: 11		// Observable 10 finished long ago, so the only remaining Observable is 11.
Done: 11
loading: false, associatedValue: -1
```
