//
//  drive.swift
//  Hyperdrive
//
//  Created by Tadeas Kriz on 17/03/2019.
//  Copyright © 2019 Brightify. All rights reserved.
//

import Foundation

public protocol HDWireframe {
}

public extension HDWireframe {

    public func connect<P: DrivenPresenter>(presenter presenterFactory: DriveFactory<P>) -> P {
        return connect(presenter: presenterFactory.build(drive:))
    }

    public func connect<P: DrivenPresenter>(presenter presenterFactory: (Drive<P>) -> P) -> P {
        let drive = Drive<P>()
        // We pause presenter drivers because they might begin emitting immediately, but we want them to propagate after connection through `present`.
        drive.pause()
        return presenterFactory(drive)
    }

    public func connect<C: DrivenController>(controller controllerFactory: DriveFactory<C>) -> C {
        return connect(controller: controllerFactory.build(drive:))
    }

    public func connect<C: DrivenController>(controller controllerFactory: (Drive<C>) -> C) -> C {
        let drive = Drive<C>()
        // We pause the controller drivers so that they don't begin emitting until connected with the presenter.
        drive.pause()
        return controllerFactory(drive)
    }

//    public func connect<C: DrivenController & PerformsNavigation>(controller controllerFactory: (Drive<C>) -> C) -> C {
//        let drive = Drive<C>()
//        // We pause the controller drivers so that they don't begin emitting until connected with the presenter.
//        drive.pause()
//        return controllerFactory(drive)
//    }

//    public func connect<C: DrivenController & PerformsNavigation>(controller controllerFactory: (Drive<C>) -> C) -> C {
//
//    }
}
