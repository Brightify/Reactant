//
//  ActionMapper+RxSwift.swift
//  RxReactant
//
//  Created by Tadeas Kriz on 18/08/2018.
//  Copyright © 2018 Brightify. All rights reserved.
//

import RxSwift

extension ActionMapper {

    public func passthrough<O: ObservableConvertibleType>(_ observable: O) where O.E == ACTION {
        let disposable = observable.asObservable()
            .subscribe(onNext: { [performAction] in
                performAction($0)
            })

        let token = ObservationToken {
            disposable.dispose()
        }

        track(token: token)
    }

}
