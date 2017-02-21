//
//  SynchronizedRecycler.swift
//  Reactant
//
//  Created by Filip Dolnik on 21.02.17.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

public class SynchronizedRecycler<T: Reusable>: Recycler<T> {
    
    private let syncQueue = DispatchQueue(label: "SynchronizedRecycler_syncQueue")
    
    public override func obtain() -> T {
        return syncQueue.sync {
            return super.obtain()
        }
    }
    
    public override func recycle(_ instance: T) {
        syncQueue.sync {
            super.recycle(instance)
        }
    }
    
    public override func recycleAll() {
        syncQueue.sync {
            super.recycleAll()
        }
    }
}
