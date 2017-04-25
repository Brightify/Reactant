//
//  Watcher.swift
//  Pods
//
//  Created by Tadeas Kriz on 4/25/17.
//
//

import Foundation
import RxSwift

public class Watcher {
    public struct Error: Swift.Error {
        public let message: String
    }

    private let subject = PublishSubject<String>()
    private let path: String
    private let queue: DispatchQueue
    private let source: DispatchSourceFileSystemObject

    init(path: String, events: DispatchSource.FileSystemEvent = .write, queue: DispatchQueue = DispatchQueue.main) throws {
        self.path = path
        self.queue = queue

        let handle = open(path , O_EVTONLY)
        guard handle != -1 else {
            throw Error(message: "Failed to open file")
        }

        source = DispatchSource.makeFileSystemObjectSource(fileDescriptor: handle, eventMask: events, queue: queue)
        source.setEventHandler { [subject] in
            subject.onNext(path)
        }

        source.setCancelHandler { [subject] in
            close(handle)
            subject.onCompleted()
        }
    }

    func watch() -> Observable<String> {
        source.resume()
        return subject
    }

    deinit {
        source.cancel()
    }
}
