//
//  ControllerBase.swift
//  Reactant
//
//  Created by Filip Dolnik on 09.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

//import RxSwift
import UIKit

open class ControllerBase<STATE, ROOT: UIView>: UIViewController, ComponentWithDelegate, Configurable where ROOT: Component {

    public typealias StateType = STATE
    public typealias ActionType = Void
    
    open var navigationBarHidden: Bool {
        return false
    }
    
    public let lifetimeTracking = ObservationTokenTracker()

    public let rootView: ROOT
    
    open var configuration: Configuration = .global {
        didSet {
            (rootView as? Configurable)?.configuration = configuration
            (view as? Configurable)?.configuration = configuration

            #if os(iOS)
            navigationItem.backBarButtonItem = configuration.get(valueFor: Properties.defaultBackButton)
            #endif
        }
    }
    
    private var castRootView: RootView? {
        return rootView as? RootView
    }

    /* The following inits are here to workaround a SegFault 11 in Swift 3.0 
       when implementation controller don't implement own init. [It's fixed in Swift 3.1] */
    public init() {
        rootView = ROOT()

        super.init(nibName: nil, bundle: nil)

        setupController(title: "")
    }

    public init(root: ROOT) {
        rootView = root

        super.init(nibName: nil, bundle: nil)

        setupController(title: "")
    }
    
    public init(title: String, root: ROOT = ROOT()) {
        rootView = root
        
        super.init(nibName: nil, bundle: nil)

        setupController(title: title)
    }

    private func setupController(title: String) {
//        componentDelegate.ownerComponent = self

        #if ENABLE_RXSWIFT
        rootView.rx.action
            .subscribe(onNext: { [weak self] in
                self?.act(on: $0)
            })
            .disposed(by: rx.lifetimeDisposeBag)
        #else
        rootView
            .observeAction(observer: { [weak self] in
                self?.act(on: $0)
            })
            .track(in: lifetimeTracking)
        #endif



        self.title = title

        reloadConfiguration()

        afterInit()
    }
    
    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open func afterInit() {
    }

    open func update() {
    }

    open func needsUpdate() -> Bool {
        return true
    }

    open func actionMapping(mapper: ActionMapper<ActionType>) {
    }

    open override func loadView() {
        view = ControllerRootViewContainer().with(configuration: configuration)
        
        view.addSubview(rootView)
    }
    
    open override func updateViewConstraints() {
        updateRootViewConstraints()
        
        super.updateViewConstraints()
    }
    
    open func updateRootViewConstraints() {
        view.removeConstraints(view.constraints)

        var constraints = [] as [NSLayoutConstraint]
        defer { NSLayoutConstraint.activate(constraints) }

        constraints += [
            rootView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            rootView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ]

        if castRootView?.edgesForExtendedLayout.contains(.top) == true {
            constraints.append(
                rootView.topAnchor.constraint(equalTo: view.topAnchor))
        } else if #available(iOS 12.0, *) {
            constraints.append(
                rootView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor))
        } else {
            constraints.append(
                rootView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor))
        }

        if castRootView?.edgesForExtendedLayout.contains(.bottom) == true {
            constraints.append(
                rootView.bottomAnchor.constraint(equalTo: view.bottomAnchor))
        } else if #available(iOS 12.0, *) {
            constraints.append(
                rootView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor))
        } else {
            constraints.append(
                rootView.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor))
        }
    }

    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        rootView.tryUpdateReactantUI()
    }

    #if ENABLE_SAFEAREAINSETS_FALLBACK
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        fallback_setViewSafeAreaInests()
    }
    #endif

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
