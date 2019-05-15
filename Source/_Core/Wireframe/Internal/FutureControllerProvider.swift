//
//  FutureControllerProvider.swift
//  Reactant
//
//  Created by Filip Dolnik on 09.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

#if canImport(UIKit)
import UIKit

public final class FutureControllerProvider<T: UIViewController> {

    /**
     * The get-only controller that provider is working with.
     *
     * Thanks to generics you can access all the methods you would expect from any subclass of **UIViewController**.
     */
    public internal(set) weak var controller: T?

    /**
     * Controller's navigation controller. Useful for not having to pass UINavigationController around.
     *
     * - NOTE: See also **UINavigationController+Navigation.swift** for useful methods.
     */
    public var navigation: UINavigationController? {
        return controller?.navigationController
    }
}
#endif
