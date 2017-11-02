//
//  AppDelegate.swift
//  TVPrototyping
//
//  Created by Matouš Hýbl on 02/11/2017.
//  Copyright © 2017 Brightify. All rights reserved.
//

import UIKit
import Reactant
import SnapKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        let window = UIWindow()
        self.window = window
        window.backgroundColor = .white
        window.rootViewController = TabController()
        window.makeKeyAndVisible()
        return true
    }
}

