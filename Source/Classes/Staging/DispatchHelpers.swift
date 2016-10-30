//
//  DispatchHelpers.swift
//  SwiftKit
//
//  Created by Tadeas Kriz on 08/01/16.
//  Copyright © 2016 Tadeas Kriz. All rights reserved.
//

import Foundation

// TODO Solve

public func cancellableDispatchAfter(_ seconds: Double, queue: DispatchQueue = DispatchQueue.main, block: @escaping () -> ()) -> Cancellable {
    let delay = DispatchTime.now() + Double(Int64(seconds * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
    return cancellableDispatchAfter(delay, on: queue, block: block)
}

public func cancellableDispatchAfter(_ time: DispatchTime, on queue: DispatchQueue, block: @escaping () -> ()) -> Cancellable {
    var cancelled: Bool = false
    queue.asyncAfter(deadline: time) {
        if cancelled == false {
            block()
        }
    }
    return CancellableToken {
        cancelled = true
    }
}

public func cancellableDispatchAsync(on queue: DispatchQueue = DispatchQueue.main, block: @escaping () -> ()) -> Cancellable {
    var cancelled: Bool = false
    
    queue.async {
        if cancelled == false {
            block()
        }
    }
    
    return CancellableToken {
        cancelled = true
    }
}
