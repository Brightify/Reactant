//
//  Rx+recording.swift
//  ReactantTests
//
//  Created by Matyáš Kříž on 17/11/2017.
//  Copyright © 2017 Brightify. All rights reserved.
//

import RxSwift
import RxTest
import Reactant

private final class RecordingObserver<ElementType>
: ObserverType {
    typealias Element = ElementType

    /// Recorded events.
    fileprivate(set) var events = [Event<Element>]()

    init() { }

    /// Notify observer about sequence event.
    ///
    /// - parameter event: Event that occurred.
    public func on(_ event: Event<Element>) {
        events.append(event)
    }
}

struct Recording<Element> {
    let events: [Event<Element>]
    let elements: [Element]
    let didComplete: Bool
    let didError: Bool
    let error: Swift.Error?

    init(events: [Event<Element>]) {
        self.events = events
        elements = events.compactMap { $0.element }

        if case .completed? = events.last {
            didComplete = true
        } else {
            didComplete = false
        }

        if case .error(let error)? = events.last {
            self.error = error
        } else {
            self.error = nil
        }
        didError = error != nil
    }
}

func recording<Element>(of recordedObservable: Observable<Element>, do work: () throws -> Void) rethrows -> Recording<Element> {
    let recordingObserver = RecordingObserver<Element>()
    let disposable = recordedObservable.subscribe(recordingObserver)
    defer { disposable.dispose() }
    try work()
    return Recording(events: recordingObserver.events)
}
