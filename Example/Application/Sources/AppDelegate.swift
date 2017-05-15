//
//  AppDelegate.swift
//  Reactant
//
//  Created by matoushybl on 03/16/2017.
//  Copyright (c) 2017 matoushybl. All rights reserved.
//

import UIKit
import Reactant

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .white
        window?.makeKeyAndVisible()

        Configuration.global.set(Properties.Style.controllerRoot) {
            $0.backgroundColor = .white
        }

        let module = AppModule()

        let wireframe = MainWireframe(dependencyModule: module)

        window?.rootViewController = wireframe.entrypoint()
        return true
    }

}

