//
//  WindowControllerBase.swift
//  Pods
//
//  Created by Tadeas Kriz on 5/5/17.
//
//

import Reactant
import RxSwift

open class WindowController: NSWindowController, Configurable, NSWindowDelegate {
    open var configuration: Configuration = .global {
        didSet {
            (view as? Configurable)?.configuration = configuration
        }
    }

    /* The following inits are here to workaround a SegFault 11 in Swift 3.0
     when implementation controller don't implement own init. [It's fixed in Swift 3.1] */
    public override init(window: NSWindow?) {
        super.init(window: window)

        window?.delegate = self

        reloadConfiguration()

        afterInit()
    }

    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override var contentViewController: NSViewController? {
        willSet {
            guard let window = window else { return }
            if newValue?.view.frame == .zero {
                newValue?.view.frame = window.contentRect(forFrameRect: window.frame)
            }
        }
    }

    open func afterInit() { }

    open func windowWillResize(_ sender: NSWindow, to frameSize: NSSize) -> NSSize {
        return frameSize
    }

    open override func windowWillLoad() {
        super.windowWillLoad()

        print(#function)
    }

    open override func windowDidLoad() {
        super.windowDidLoad()

        print(#function)
    }

    open override func loadWindow() {
        super.loadWindow()

        print(#function)
    }
    //    open override func loadView() {
    //        view = ControllerRootViewContainer().with(configuration: configuration)
    //
    //        view.addSubview(rootView)
    //    }

    //    open override func updateViewConstraints() {
    //        updateRootViewConstraints()
    //
    //        super.updateViewConstraints()
    //    }

//    open func updateRootViewConstraints() {
        //        rootView.snp.remakeConstraints { make in
        //            make.leading.equalTo(view)
        //            make.trailing.equalTo(view)
        //            make.top.equalTo(view)
        //            make.bottom.equalTo(view).priority(NSLayoutPriorityDefaultHigh)
        //        }
//    }

    //    open override func viewWillAppear() {
    //        super.viewWillAppear()
    //
    //        componentDelegate.canUpdate = true
    //
    //        castRootView?.viewWillAppear()
    //    }
    //
    //    open override func viewDidAppear() {
    //        super.viewDidAppear()
    //
    //        castRootView?.viewDidAppear()
    //    }
    //
    //    open override func viewWillDisappear() {
    //        super.viewWillDisappear()
    //
    //        componentDelegate.canUpdate = false
    //
    //        castRootView?.viewWillDisappear()
    //    }
    //
    //    open override func viewDidDisappear() {
    //        super.viewDidDisappear()
    //        
    //        castRootView?.viewDidDisappear()
    //    }
}
