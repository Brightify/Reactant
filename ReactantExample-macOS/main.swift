//
//  main.swift
//  Reactant
//
//  Created by Tadeas Kriz on 5/5/17.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Cocoa

let delegate = AppDelegate() //alloc main app's delegate class
NSApplication.shared().delegate = delegate //set as app's delegate

let ret = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
