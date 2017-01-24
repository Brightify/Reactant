//
//  Recycler.swift
//  Reactant
//
//  Created by Tadeáš Kříž on 1/24/17.
//  Copyright © 2017 Brightify. All rights reserved.
//

// FIXME Might need improved thread safety!
public class Recycler<T: Reusable> {
    private var instancesInUse: [T] = []
    private var recycledInstances: [T]

    private let itemFactory: () -> T
    private let capacity: Int

    init(capacity: Int = Int.max, initialInstances: Int = 0, factory: @escaping () -> T) {
        precondition(capacity > 0, "Capacity cannot be negative. Use Int.max to disable instance limit.")
        precondition(initialInstances >= 0, "Number of initial instances cannot be negative.")
        self.capacity = capacity

        itemFactory = factory

        if initialInstances > 0 {
            recycledInstances = (1...initialInstances).map { _ in factory() }
        } else {
            recycledInstances = []
        }
    }

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

    public func recycle(_ instance: T) {
        if let index = instancesInUse.index(where: { $0 === instance }) {
            instancesInUse.remove(at: index)
        } else if recycledInstances.contains(where: { $0 === instance }) {
            fatalError("Trying to recycle already recycled instance! Instance: \(instance)")
        } else {
            fatalError("Trying to recycle an unknown instance! You can recycle only instances previously obtained using `obtain` method. Instance: \(instance)")
        }

        instance.prepareForReuse()

        if recycledInstances.count < capacity {
            recycledInstances.append(instance)
        }
    }

    public func recycleAll() {
        let instancesToRecycle = instancesInUse
        instancesInUse.removeAll(keepingCapacity: true)

        instancesToRecycle.forEach { $0.prepareForReuse() }

        let unusedCapacity = capacity - recycledInstances.count
        if unusedCapacity > 0 {
            recycledInstances.append(contentsOf: instancesToRecycle.prefix(unusedCapacity))
        }
    }
}
