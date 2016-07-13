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

enum ModelState {
    case Set
    case NotSet
}

class ControllerBase<STATE, ROOT: UIView>: UIViewController, DialogDismissalListener, Component {
    let rootView: ROOT
    
    public var componentState: STATE {
        get {
            if let state = stateStorage {
                return state
            } else {
                fatalError("Model accessed before stored!")
            }
        }
        set {
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
    
    var navigationBarHidden: Bool {
        return false
    }

    public let lifecycleDisposeBag = DisposeBag()
    public var stateDisposeBag = DisposeBag()

    init(title: String = "") {
        rootView = self.dynamicType.initializeRootView()

        super.init(nibName: nil, bundle: nil)

        self.title = title
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style:.Plain)
        
        // If the model is Void, we set it so caller does not have to. Calling it multiple times before canRender does not decrease performance.
        if let voidState = Void() as? STATE {
            componentState = voidState
        }
    }

    class func initializeRootView() -> ROOT {
        return ROOT()
    }
    
    func renderIfPossible() {
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
        render()
    }

    func render() { }

    func updateRootViewConstraints() {
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
    
    override func loadView() {
        // FIXME Add common styles and style rootview
        view = ControllerRootView().styled(using: ProjectBaseConfiguration.global.controllerRootStyle)

        view.addSubview(rootView)
    }

    override func updateViewConstraints() {
        updateRootViewConstraints()

        super.updateViewConstraints()
    }

    func dialogWillDismiss() {
        renderIfPossible()
    }

    func dialogDidDismiss() { }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(navigationBarHidden, animated: animated)

        canRender = true

        rootView.willAppear(animated)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        rootView.didAppear(animated)
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        rootView.willDisappear(animated)
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        canRender = false
        
        stateDisposeBag = DisposeBag()
        
        rootView.didDisappear(animated)
    }
}

protocol DialogDismissalListener {
    func dialogWillDismiss()
    
    func dialogDidDismiss()
}
