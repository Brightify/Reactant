//
//  ControllerBase.swift
//  Pods
//
//  Created by Tadeáš Kříž on 12/06/16.
//
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Lipstick

public class ControllerBase<STATE, ROOT: UIView>: UIViewController, DialogDismissalListener, Component {
    public let rootView: ROOT

    public private(set) var previousComponentState: STATE?
    public var componentState: STATE {
        get {
            if let state = stateStorage {
                return state
            } else {
                fatalError("Model accessed before stored!")
            }
        }
        set {
            previousComponentState = stateStorage
            stateStorage = newValue
            renderIfPossible()
        }
    }
    private var stateStorage: STATE?
    private var canRender = false {
        willSet {
            if newValue == canRender {
                print("WARNING: Unbalanced calls items in `canRender` sequence. Use `forceRender` to force a render!")
            }
        }
        didSet {
            if oldValue != canRender {
                renderIfPossible()
            }
        }
    }
    
    public var navigationBarHidden: Bool {
        return false
    }

    /// DisposeBag for one-time subscriptions made in init. It is reset just before deallocating.
    public let lifetimeDisposeBag = DisposeBag()

    /// DisposeBag for actions from other controllers. This is reset before each `render` call.
    public private(set) var controllersActionsBag = DisposeBag()

    /// DisposeBag for actions in `render`. This is reset before each `render` call and in `viewWillDisappear`.
    public private(set) var stateDisposeBag = DisposeBag()

    public init(title: String = "") {
        rootView = self.dynamicType.initializeRootView()

        super.init(nibName: nil, bundle: nil)

        self.title = title
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style:.Plain)
        
        // If the model is Void, we set it so caller does not have to. Calling it multiple times before canRender does not decrease performance.
        if let voidState = Void() as? STATE {
            componentState = voidState
        }
    }

    public class func initializeRootView() -> ROOT {
        return ROOT()
    }
    
    public func renderIfPossible() {
        guard canRender else { return }
        guard stateStorage != nil else {
            #if DEBUG
                fatalError("Model not set before render was enabled! Model \(STATE.self), controller \(self.dynamicType)")
            #else
                print("WARNING: Model not set before render was enabled. This is usually developer error by not calling `setModel` on controller that need non-Void model. Controller \(self.dynamicType) needs \(STATE.self)!")
                return
            #endif
        }
        
        stateDisposeBag = DisposeBag()
        controllersActionsBag = DisposeBag()
        render()
    }

    public func render() { }

    public func updateRootViewConstraints() {
        rootView.snp_updateConstraints { make in
            make.leading.equalTo(view)
            if rootView.edgesForExtendedLayout.contains(.Top) {
                make.top.equalTo(view)
            } else {
                make.top.equalTo(snp_topLayoutGuideBottom)
            }
            make.trailing.equalTo(view)
            if rootView.edgesForExtendedLayout.contains(.Bottom) {
                make.bottom.equalTo(view).priorityMedium()
            } else {
                make.bottom.equalTo(snp_bottomLayoutGuideTop).priorityMedium()
            }
        }
    }
    
    public override func loadView() {
        // FIXME Add common styles and style rootview
        view = ControllerRootView().styled(using: ProjectBaseConfiguration.global.controllerRootStyle)

        view.addSubview(rootView)
    }

    public override func updateViewConstraints() {
        updateRootViewConstraints()

        super.updateViewConstraints()
    }

    public func dialogWillDismiss() {
        renderIfPossible()
    }

    public func dialogDidDismiss() { }

    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(navigationBarHidden, animated: animated)

        canRender = true

        rootView.willAppearInternal(animated)
    }

    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        rootView.didAppearInternal(animated)
    }

    public override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        rootView.willDisappearInternal(animated)
    }

    public override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        canRender = false
        
        stateDisposeBag = DisposeBag()
        
        rootView.didDisappearInternal(animated)
    }
}

public protocol DialogDismissalListener {
    func dialogWillDismiss()
    
    func dialogDidDismiss()
}
