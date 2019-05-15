//
//  ControllerBase.swift
//  Reactant
//
//  Created by Filip Dolnik on 09.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

//import RxSwift
#if canImport(UIKit)
import UIKit

//public protocol HyperView: AnyObject {
//    associatedtype State: HyperViewState
//    associatedtype Action
//
//    init(actionPublisher: ActionPublisher<Action>)
//
//    func set(state: State)
//
//    func apply(change: State.Change)
//}
//
//public class ActionPublisher<Action> {
//    public func publish(action: Action) {
//
//    }
//}
//
//public protocol HyperViewState {
//    associatedtype Change
//
//    mutating func mutateRecordingChanges(mutation: (inout Self) -> Void) -> [Change]
//
//    mutating func apply(change: Change)
//}
//
//struct SomeState: HyperViewState {
//    private var changes: [Change]? = nil
//
//    var title: String {
//        didSet {
//            changes?.append(.titleChanged(title))
//        }
//    }
//    var message: String {
//        didSet {
//            changes?.append(.messageChanged(message))
//        }
//    }
//
//    mutating func mutateRecordingChanges(mutation: (inout SomeState) -> Void) -> [Change] {
//        var mutableState = self
//        mutableState.changes = []
//
//        mutation(&mutableState)
//
//        let changes = mutableState.changes
//        mutableState.changes = nil
//
//        self = mutableState
//
//        return changes ?? []
//    }
//
//    enum Change {
//        case titleChanged(String)
//        case messageChanged(String)
//    }
//}
//
//public class HyperViewManager<View: UIView & HyperView> {
//    private var state: View.State
//    private weak var view: View? {
//        didSet {
//            notifyViewChanged()
//        }
//    }
//
//    public init(initialState: View.State) {
//        state = initialState
//    }
//
//    public func load(actionHandler: (View.Action) -> Void) -> UIView {
//
//    }
//
//    public func mutateViewState(with mutation: (inout View.State) -> Void) {
//        let changes = state.mutateRecordingChanges(mutation: mutation)
//        submit(viewChanges: changes)
//    }
//
//    private func submit(viewChanges: [View.State.Change]) {
//        mutateViewState { state in
//            for change in viewChanges {
//                view?.apply(change: change)
//            }
//        }
//    }
//
//    private func notifyViewChanged() {
//        view?.set(state: state)
//    }
//}

open class ControllerBase<STATE, ROOT: UIView>: UIViewController, ComponentWithDelegate, Configurable where ROOT: _Component {

    public typealias StateType = STATE
    public typealias ActionType = Void
    
    open var navigationBarHidden: Bool {
        return false
    }
    
    public let lifetimeTracking = ObservationTokenTracker()

    public let componentDelegate: ComponentDelegate<STATE, Void>

    public private(set) lazy var rootView: ROOT = rootViewFactory()
    private let rootViewFactory: () -> ROOT

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

    public init(initialState: STATE, rootViewFactory: @autoclosure @escaping () -> ROOT) {
        self.rootViewFactory = rootViewFactory

        componentDelegate = ComponentDelegate(initialState: initialState)
        super.init(nibName: nil, bundle: nil)
        componentDelegate.setOwner(self)

        setupController()
    }

    private func setupController() {
        rootView
            .observeAction(observer: { [weak self] in
                self?.act(on: $0)
            })
            .track(in: lifetimeTracking)

        reloadConfiguration()

        afterInit()
    }
    
    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open func afterInit() {
    }

    open func update(previousState: StateType?) {
    }

    open func needsUpdate(previousState: StateType?) -> Bool {
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
        } else if #available(iOS 11.0, tvOS 11.0, *) {
            constraints.append(
                rootView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor))
        } else {
            constraints.append(
                rootView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor))
        }

        if castRootView?.edgesForExtendedLayout.contains(.bottom) == true {
            constraints.append(
                rootView.bottomAnchor.constraint(equalTo: view.bottomAnchor))
        } else if #available(iOS 11.0, tvOS 11.0, *) {
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

extension ControllerBase where STATE == Void {
    public convenience init(rootViewFactory: @autoclosure @escaping () -> ROOT) {
        self.init(initialState: (), rootViewFactory: rootViewFactory())
    }
}
#endif
