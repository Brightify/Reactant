//
//  AppDelegate.swift
//  ReactantPrototyping
//
//  Created by Filip Dolnik on 16.02.17.
//  Copyright © 2017 Brightify. All rights reserved.
//

import UIKit
import ReactantLiveUI

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        let window = UIWindow()
        self.window = window
        window.backgroundColor = .white
        window.rootViewController = ViewController()
        window.makeKeyAndVisible()
        ReactantLiveUIManager.shared.activate(in: window, configuration: GeneratedReactantLiveUIConfiguration())
        return true
    }
}

