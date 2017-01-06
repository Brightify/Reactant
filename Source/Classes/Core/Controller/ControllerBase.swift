//
//  ControllerBase.swift
//  Reactant
//
//  Created by Filip Dolnik on 09.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import SnapKit
import RxSwift

open class ControllerBase<STATE, ROOT: UIView>: UIViewController, ComponentWithDelegate where ROOT: Component {
    
    public typealias StateType = STATE
    public typealias ActionType = Void
    
    open var navigationBarHidden: Bool {
        return false
    }
    
    public let lifetimeDisposeBag = DisposeBag()
    
    public let componentDelegate = ComponentDelegate<STATE, Void, ControllerBase<STATE, ROOT>>()
    
    public let action: Observable<Void> = Observable.empty()
    
    public let actions: [Observable<Void>] = []
    
    public let rootView: ROOT
    
    private var castRootView: RootView? {
        return rootView as? RootView
    }
    
    public init(title: String = "", root: ROOT = ROOT()) {
        rootView = root
        
        super.init(nibName: nil, bundle: nil)
        
        componentDelegate.ownerComponent = self
        rootView.action.subscribe(onNext: act).addDisposableTo(lifetimeDisposeBag)
        
        self.title = title
        
        afterInit()
    }
    
    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        preconditionFailure("init(coder:) has not been implemented")
    }

    open func afterInit() { }

    open func update() { }
    
    open override func loadView() {
        // FIXME Add common styles and style rootview
        view = ControllerRootViewContainer()
        
        view.addSubview(rootView)
    }
    
    open override func updateViewConstraints() {
        updateRootViewConstraints()
        
        super.updateViewConstraints()
    }
    
    open func updateRootViewConstraints() {
        rootView.snp.updateConstraints { make in
            make.leading.equalTo(view)
            if castRootView?.edgesForExtendedLayout.contains(.top) == true {
                make.top.equalTo(view)
            } else {
                make.top.equalTo(topLayoutGuide.snp.bottom)
            }
            make.trailing.equalTo(view)
            if castRootView?.edgesForExtendedLayout.contains(.bottom) == true {
                make.bottom.equalTo(view).priority(UILayoutPriorityDefaultHigh)
            } else {
                make.bottom.equalTo(bottomLayoutGuide.snp.top).priority(UILayoutPriorityDefaultHigh)
            }
        }
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(navigationBarHidden, animated: animated)
        
        componentDelegate.canUpdate = true
        
        castRootView?.viewWillAppear()
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        castRootView?.viewDidAppear()
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        componentDelegate.canUpdate = false
        
        castRootView?.viewWillDisappear()
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        castRootView?.viewDidDisappear()
    }
    
    public final func perform(action: Void) {
    }
    
    public final func resetActions() {
    }
    
    open func act(on action: ROOT.ActionType) {
    }
}
