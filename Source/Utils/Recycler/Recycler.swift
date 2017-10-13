//
//  Recycler.swift
//  Reactant
//
//  Created by Tadeáš Kříž on 1/24/17.
//  Copyright © 2017 Brightify. All rights reserved.
//

public class Recycler<T: AnyObject> {

    private var instancesInUse: [T] = []
    private var recycledInstances: [T]

    private let prepareForReuse: (T) -> Void
    private let itemFactory: () -> T
    private let capacity: Int

    /**
     * - parameter capacity: determines how many instances should be kept ready in the recycler, default is `Int.max`
     * - parameter initialInstances: determines how many instances should be created in advance, default is `0`
     * - parameter prepareForReuse: closure called on every instance to reset it before saving it into recycled instances
     * - parameter factory: closure called whenever a new instance needs to be created (when there are no recycled instances)
     */
    public init(capacity: Int = Int.max, initialInstances: Int = 0, prepareForReuse: @escaping (T) -> Void, factory: @escaping () -> T) {
        precondition(capacity > 0, "Capacity cannot be negative. Use Int.max to disable instance limit.")
        precondition(initialInstances >= 0, "Number of initial instances cannot be negative.")
        self.capacity = capacity

        self.prepareForReuse = prepareForReuse
        self.itemFactory = factory

        if initialInstances > 0 {
            recycledInstances = (1...initialInstances).map { _ in factory() }
        } else {
            recycledInstances = []
        }
    }

    /**
     * Get an object from the `Recycler`.
     * - returns: new initialized instance or one from the recycled instances
     */
    public func obtain() -> T {
        if let recycledItem = recycledInstances.popLast() {
            instancesInUse.append(recycledItem)
            return recycledItem
        } else {
            let newItem = itemFactory()
            instancesInUse.append(newItem)
            return newItem
        }
    }

    /**
     * Recycle an instance obtained by calling `obtain()`.
     * - parameter instance: instance you wish to add to recycled instances
     * - NOTE: `prepareForReuse` (set in **init**) will be called automatically.
     */
    public func recycle(_ instance: T) {
        if let index = instancesInUse.index(where: { $0 === instance }) {
            instancesInUse.remove(at: index)
        } else if recycledInstances.contains(where: { $0 === instance }) {
            fatalError("Trying to recycle already recycled instance! Instance: \(instance)")
        } else {
            fatalError("Trying to recycle an unknown instance! You can recycle only instances previously obtained using `obtain` method. Instance: \(instance)")
        }

        prepareForReuse(instance)

        if recycledInstances.count < capacity {
            recycledInstances.append(instance)
        }
    }

    /**
     * Remove all instances from use and prepare them for next usage.
     * - NOTE: `prepareForReuse` (set in **init**) will be called automatically on each instance
     */
    public func recycleAll() {
        let instancesToRecycle = instancesInUse
        instancesInUse.removeAll(keepingCapacity: true)

        instancesToRecycle.forEach(prepareForReuse)

        let unusedCapacity = capacity - recycledInstances.count
        if unusedCapacity > 0 {
            recycledInstances.append(contentsOf: instancesToRecycle.prefix(unusedCapacity))
        }
    }
}

extension Recycler where T: Reusable {
    /**
     * Convenience init for Components which conform to the `Reusable` protocol.
     * - parameter capacity: determines how many instances should be kept ready in the recycler, default is `Int.max`
     * - parameter initialInstances: determines how many instances should be created in advance, default is `0`
     * - parameter factory: closure called whenever a new instance needs to be created (when there are no recycled instances)
     * - NOTE: `prepareForReuse` is taken from the Component itself.
     */
    public convenience init(capacity: Int = Int.max, initialInstances: Int = 0, factory: @escaping () -> T) {
        self.init(
            capacity: capacity,
            initialInstances: initialInstances,
            prepareForReuse: { $0.prepareForReuse() },
            factory: factory)
    }
}
