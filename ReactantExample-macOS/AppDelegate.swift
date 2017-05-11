//
//  AppDelegate.swift
//  ReactantExample-macOS
//
//  Created by Tadeas Kriz on 5/5/17.
//  Copyright © 2017 Brightify. All rights reserved.
//


import Reactant
import RxSwift
import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {

    let windowController = TestWindowController(
        window: NSWindow(contentRect: NSMakeRect(100, 100, NSScreen.main()!.frame.width/2, NSScreen.main()!.frame.height/2),
                         styleMask: [.titled, .resizable, .miniaturizable, .closable],
                         backing: .buffered,
                         defer: false)
    )


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        windowController.showWindow(self)
        print(windowController.window)

        windowController.contentViewController = TestController()

    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

}

//open class WindowControllerBase: NSWindowController

//func newWindow() -> NSWindowController {
//    let window = NSWindow(contentRect: <#T##NSRect#>, styleMask: <#T##NSWindowStyleMask#>, backing: <#T##NSBackingStoreType#>, defer: <#T##Bool#>, screen: <#T##NSScreen?#>)
//}

class TestRootView: ViewBase<Void, Void> {
    let label = Label()

    override func loadView() {
        children(
            label
        )

        label.stringValue = "Hello!"
    }

    override func setupConstraints() {
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.equalToSuperview().inset(50)
            make.trailing.equalToSuperview().inset(50)
            make.top.greaterThanOrEqualToSuperview().inset(50)
            make.bottom.lessThanOrEqualToSuperview().inset(50)
        }
    }
}

class TestWindowController: WindowControllerBase<Void, TestRootView> {
    
}

class TestController: ControllerBase<Void, TestRootView> {

}
