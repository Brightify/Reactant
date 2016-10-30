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

open class ControllerBase<STATE, ROOT: UIView>: UIViewController, DialogDismissalListener, Component {
    open let rootView: ROOT

    open var observableState: Observable<STATE> {
        return observableStateSubject
    }
    private let observableStateSubject = ReplaySubject<STATE>.create(bufferSize: 1)

    open var previousComponentState: STATE? {
        return previousStateStorage.value
    }
    private let previousStateStorage = StateBox<STATE?>(value: nil)
    open var componentState: STATE {
        get {
            if let state = stateStorage.value {
                return state
            } else {
                fatalError("Model accessed before stored!")
            }
        }
        set {
            previousStateStorage.value = stateStorage.value
            stateStorage.value = newValue
            observableStateSubject.onNext(newValue)
            renderIfPossible()
        }
    }
    private let stateStorage = StateBox<STATE?>(value: nil)
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
    
    open var navigationBarHidden: Bool {
        return false
    }

    /// DisposeBag for one-time subscriptions made in init. It is reset just before deallocating.
    open let lifetimeDisposeBag = DisposeBag()

    /// DisposeBag for actions from other controllers. This is reset before each `render` call.
    open private(set) var controllersActionsBag = DisposeBag()

    /** We need to keep this until viewWillAppear is called to not dispose controller actions when user just peeks
       back to this controller */
    private var previousControllersActionsBag: DisposeBag?

    /// DisposeBag for actions in `render`. This is reset before each `render` call and in `viewWillDisappear`.
    open private(set) var stateDisposeBag = DisposeBag()

    public init(title: String = "", root: ROOT = ROOT()) {
        rootView = root

        super.init(nibName: nil, bundle: nil)

        self.title = title
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)

        // If the model is Void, we set it so caller does not have to. Calling it multiple times before canRender does not decrease performance.
        if let voidState = Void() as? STATE {
            componentState = voidState
        }
    }

    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open func renderIfPossible() {
        guard canRender else { return }
        guard stateStorage.value != nil else {
            #if DEBUG
                fatalError("Model not set before render was enabled! Model \(STATE.self), controller \(type(of: self))")
            #else
                print("WARNING: Model not set before render was enabled. This is usually developer error by not calling `setModel` on controller that need non-Void model. Controller \(type(of: self)) needs \(STATE.self)!")
                return
            #endif
        }

        stateDisposeBag = DisposeBag()
        controllersActionsBag = DisposeBag()
        render()
    }

    open func render() { }

    open func updateRootViewConstraints() {
        rootView.snp.updateConstraints { make in
            make.leading.equalTo(view)
            if rootView.edgesForExtendedLayout.contains(.top) {
                make.top.equalTo(view)
            } else {
                make.top.equalTo(topLayoutGuide.snp.bottom)
            }
            make.trailing.equalTo(view)
            if rootView.edgesForExtendedLayout.contains(.bottom) {
                make.bottom.equalTo(view).priority(UILayoutPriorityDefaultHigh)
            } else {
                make.bottom.equalTo(bottomLayoutGuide.snp.top).priority(UILayoutPriorityDefaultHigh)
            }
        }
    }
    
    open override func loadView() {
        // FIXME Add common styles and style rootview
        let controllerRootView = ControllerRootView()
        ReactantConfiguration.global.controllerRootStyle(controllerRootView)
        view = controllerRootView

        view.addSubview(rootView)
    }

    open override func updateViewConstraints() {
        updateRootViewConstraints()

        super.updateViewConstraints()
    }

    open func dialogWillDismiss() {
        renderIfPossible()
    }

    open func dialogDidDismiss() { }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(navigationBarHidden, animated: animated)

        // Save the previous dispose bag in case this controller will not appear after all.
        previousControllersActionsBag = controllersActionsBag

        canRender = true

        rootView.willAppearInternal(animated: animated)
    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        rootView.didAppearInternal(animated: animated)

        previousControllersActionsBag = nil
    }

    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        canRender = false

        // If the the bag is not reset to nil, then `didAppear` was not called and we have to keep the old bag.
        if let previousControllersActionsBag = previousControllersActionsBag {
            controllersActionsBag = previousControllersActionsBag
        }

        stateDisposeBag = DisposeBag()

        rootView.willDisappearInternal(animated: animated)
    }

    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        rootView.didDisappearInternal(animated: animated)
    }
}

public protocol DialogDismissalListener {
    func dialogWillDismiss()
    
    func dialogDidDismiss()
}
