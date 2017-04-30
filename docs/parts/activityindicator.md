ActivityIndicator
=================

`ActivityIndicator` allows you to track activity of `Observable`. It is especially useful when displaying progress of some tasks done by multiple `Observable` in a row, because it can monitor all of them and show different messages based on the current task.

`ActivityIndicator` has this init: `init(defaultMessage: String? = nil)`. Meaning of `defaultMessage` will be explained later.

To register `Observable` to be tracked by `ActivityIndicator` use:

```swift
extension ActivityIndicator {
    
	// defaultMessage from init will be associated to this Observable.
    func trackActivity<O: ObservableConvertibleType>(of source: O)
    
    // Provided message will be used instead of the default one.
    func trackActivity<O: ObservableConvertibleType>(of source: O, message: String?)
    
    // Associated message will be determined for each value from Observable individually by messageProvider. defaultMessage will be used as the first message.
    func trackActivity<O: ObservableConvertibleType>(of source: O, messageProvider: @escaping (O.E) -> String?)

	// Same as method above, but initialMessage is provided explicitly.
    func trackActivity<O: ObservableConvertibleType>(of source: O, initialMessage: String?, messageProvider: @escaping (O.E) -> String?) -> Observable<O.E>
}
```

For example:

```swift 
let activityIndicator = ActivityIndicator()
let observable = Observable<Int>.interval(RxTimeInterval(1), scheduler: MainScheduler.instance)
								.take(10)

activityIndicator.trackActivity(of: observable)

observable.subscribe...
```

Usually you do not store `Observable` in a variable (doing so requires to break the chain of function calls). To remove this restriction use these corresponding methods from extension of `ObservableConvertibleType`:

```swift
extension ObservableConvertibleType {
    
    func trackActivity(in activityIndicator: ActivityIndicator) -> Observable<E> 
    
    func trackActivity(in activityIndicator: ActivityIndicator, message: String?) -> Observable<E> 
    
    func trackActivity(in activityIndicator: ActivityIndicator, messageProvider: @escaping (E) -> String?) -> Observable<E> 
    
    func trackActivity(in activityIndicator: ActivityIndicator, initialMessage: String?, messageProvider: @escaping (E) -> String?) -> Observable<E>
}
```

Now we can integrate `ActivityIndicator` to existing `Observable` chain quite nicely:

```swift 
let activityIndicator = ActivityIndicator()
let observable = Observable<Int>.interval(RxTimeInterval(1), scheduler: MainScheduler.instance)
								.take(10)
								.trackActivity(in: activityIndicator)
								.subscribe...
```

All of the `trackActivity` methods captures `ActivityIndicator` until the registered `Observable` is disposed. So you do not have to hold a reference to it.

Example of `messageProvider`:

```swift
let activityIndicator = ActivityIndicator()
activityIndicator.asObservable().subscribe(onNext: {
    print("loading: \($0.loading), message: \($0.message ?? "Empty")")
}).disposed(by: activityIndicator.disposeBag)

Observable<Int>.interval(RxTimeInterval(1), scheduler: MainScheduler.instance)
            .trackActivity(in: activityIndicator, initialMessage: "-1", messageProvider: { "\($0)" })
            .subscribe(onNext: { _ in }).disposed(by: lifetimeDisposeBag)
```

Output:

```
loading: false, message: Empty
loading: true, message: -1
loading: true, message: 0
loading: true, message: 1
...
```

To access data produced by `ActivityIndicator` use `asDriver()` or `asObservable`. For example:

```swift
activityIndicator.asObservable()
				 .subscribe(onNext: {
            			print("loading: \($0.loading), message: \($0.message ?? "")")
				 }).disposed(by: activityIndicator.disposeBag)
```

Notice the `activityIndicator.disposeBag`. It is not necessary to add `ActivityIndicator` subscriptions to a `DisposeBag` because they will be released automatically together with the instance of `ActivityIndicator` (so using `activityIndicator.disposeBag` in this case is equivalent to not using any at all). Nevertheless it is recommended to do so. It will help the code readability and also without `disposed(by:)` Xcode produces a warning.

`loading` is a `bool` value that tells if `ActivityIndicator` currently tracks at least one active `Observable` (once `Observable` finishes its work, it is disposed and not considered active). Message is `String?` associated with the first active `Observable` (the order of multiple `Observable` is determined by the order they were registered to `ActivityIndicator`). If `loading` is `false`, then `message` is set to `nil`.

`onNext` is called only when there is a change either in `loading` or `message`.

Advanced example:

```swift
let activityIndicator = ActivityIndicator()
activityIndicator.asObservable()
				 .subscribe(onNext: {
    					print("loading: \($0.loading), message: \($0.message ?? "Empty")")	// If message is nil, print Empty instead.
				 }).disposed(by: activityIndicator.disposeBag)

// Function that creates some Observable emulating long operation (fetching data from disk, etc.).
func createObservable(value: Int, delay: Int) -> Observable<Int> {
    return Observable<Int>.just(value).delay(RxTimeInterval(delay), scheduler: MainScheduler.instance)
}

// Represents serial sequence of three Observable, each takes two seconds to compute. The trackActivity is called immediately so the priority of Observables is: 1, 2, 3, 10, 11 regardless of when they actually start doing something.
createObservable(value: 1, delay: 2)
    .trackActivity(in: activityIndicator, message: "1")
    .flatMap { value -> Observable<Int> in
        print("Done: \(value)")
        return createObservable(value: 2, delay: 2)
    }.trackActivity(in: activityIndicator, message: "2")
    .flatMap { value -> Observable<Int> in
        print("Done: \(value)")
        return createObservable(value: 3, delay: 2)
    }.trackActivity(in: activityIndicator, message: "3")
    .subscribe(onNext: { print("Done: \($0)") })
    .disposed(by: lifetimeDisposeBag)

// ActivityIndicator can track multiple Observables in parallel.
createObservable(value: 10, delay: 3)
    .trackActivity(in: activityIndicator, message: "10")
    .flatMap { value -> Observable<Int> in
        print("Done: \(value)")
        return createObservable(value: 11, delay: 5)
    }.trackActivity(in: activityIndicator, message: "11")
    .subscribe(onNext: { print("Done: \($0)") })
    .disposed(by: lifetimeDisposeBag)
```

The output of this code is:
```
loading: false, message: Empty
loading: true, message: 1
Done: 1
loading: true, message: 2 		// Observable 2 is registered before 10.
Done: 10						// Observable 10 finishes before 2 but that doesn't change the message.
Done: 2
loading: true, message: 3
Done: 3
loading: true, message: 11		// Observable 10 finished long ago, so the only remaining Observable is 11.
Done: 11
loading: false, message: Empty
```

