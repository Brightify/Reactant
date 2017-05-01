Configuration
=================

`Configuration` is a key-value storage. It is mainly used to set default values in classes like `BaseController` or `ViewBase`. 

`Configuration` provides these methods for storing and retrieving values:

```swift
class Configuration {
    
    func set<T>(_ property: Property<T>, to value: T)
    
    func get<T>(valueFor property: Property<T>) -> T
}
```

## Property

As you can see, `Configuration` uses `Property` as keys. 

```swift
struct Property<T> {
    
    let id: Int
    let defaultValue: T
    
    init(defaultValue: T)
}
```

`Property` defines type of value it points to (`T`). Field `id` is unique identifier for each object. So in order to retrieve value previously stored, you have to use the same instance of `Property` (passing `Property` by value doesn't change `id`). 

Example:

```swift
let configuration = Configuration()

let integer = Property(defaultValue: 1)
let optionalInteger = Property<Int?>()

configuration.get(valueFor: integer) 			// returns 1
configuration.get(valueFor: optionalInteger) 	// returns nil

configuration.set(integer, to: 5)
configuration.set(optionalInteger, to: 0)

configuration.get(valueFor: integer) 			// returns 5
configuration.get(valueFor: optionalInteger) 	// returns 0
```

Notice that `defaultValue` from `Property.init` is used when no value for that `Property` was previously stored inside `Configuration`. Also `Optional` types do not require `defaultValue`, in that case it will be `nil`.

To create custom property simply make a new instance of `Property`: 

```swift
let newProperty = Property<Int>(defaultValue: 0)
```

It is recommended to put it inside an extension of `Properties` (see below).

## Properties

`Properties` is a struct used to store instances of `Property`. Each part of Reactant can define new properties by simply adding them to `Properties` by extension. For example:

```swift
extension Properties {

	static let layoutMargins = Property<UIEdgeInsets>(defaultValue: .zero)
}
```

Concrete instances of `Property` are covered in documentation for parts of Reactant which uses them.

## Global and custom configuration

Global configuration is a special instance of `Configuration` accessible by `Configuration.global`. This configuration is the default one for all things in Reactant. It is applied at the end of `init`.

If you need to change configuration but only for some classes. You can create your own instance of `Configuration` by calling `init(copy: Configuration...)`. Notice the optional `copy` parameter, you can "inherit" the common settings for example from `Configuration.global` and then make your changes, while leaving the `Configuration.global` intact. Also it is possible to copy configuration from multiple instances of `Configuration`. Most likely that will result in conflict of some properties. In that case the priority is: `init(copy: leastSignificant, ..., mostSignificant)`. When you have your custom `Configuration` ready, assign it to instance of `Configurable` by `instance.configuration = customConfiguration`.

## Configurable

`Configurable` is a helping protocol for classes that wants to use data from `Configuration`.

```swift
protocol Configurable: class {
    
    var configuration: Configuration { get set }
}

extension Configurable {
    
    /// Calls didSet on configuration.
    func reloadConfiguration()
    
    /// Applies configuration to this object and returns it to allow chaining.
    func with(configuration: Configuration) -> Self
}
```

You should access `configuration` only from its `didSet` listener. This ensures, that everything is properly changed together with the instance of `Configuration`.

This example part of implementation from `ControllerBase` shows how to implement `Configurable` from scratch:

```swift
class ControllerBase ... {

...

	var configuration: Configuration = .global { // Default configuration is .global.
	    didSet {
	        (rootView as? Configurable)?.configuration = configuration // New instance of configuration is propagated through the dependency tree.
	        ...
	        navigationItem.backBarButtonItem = configuration.get(valueFor: Properties.defaultBackButton) // Accessing values.
	    }
	}

	init() {
		...
		reloadConfiguration() // didSet is not called when default value is assigned. This must be called after the class is initialized.
	}

...

}
```

Usually you will inherit from some class that already implements `Configurable`. Then it is much easier to use `configuration`:

```swift
class CustomView: ViewBase... { // ViewBase implements Configurable

	override var configuration: Configuration { // No .global assignment (already in super class).
		didSet { // No need to call anything from super class. Swift does that automatically.
		    ... // Do something.
		}
	}

	// No call of reloadConfiguration() (done in super.init).
}
```