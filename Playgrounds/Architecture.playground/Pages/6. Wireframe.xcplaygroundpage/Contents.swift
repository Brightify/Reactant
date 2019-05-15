/*: [Previous](@previous)

 # 6. Wireframe

 Wireframe is connecting presenters with view controllers and navigating between view controllers.

 Wireframe has no logic.

 Wireframe can never decide between different presenters based on the model. Instead it has to ask the presenter to decide which presenter factory should be used to create the wanted presenter.

 Wireframe has zero `if` statements.

 Wireframe can have `switch` statements for navigation actions only.


 */

import UIKit
import Hyperdrive

class MainWireframe: HDWireframe {

    private func initial() -> UIViewController {
        let inner = drive(presenter: InnerPresenter.init)
        let presenter = drive { driver in
            InitialPresenter(driver: driver, inner: inner)
        }
        let controller = drive(controller: InitialController.init)

        return presenter.present(controller: controller) { route in
            switch route {
            case .login:

            }
        }
    }
}

final class InnerPresenter: DrivenPresenter {
    enum Event {
        case applicationLoaded
    }
    enum HandledAction {
        case someAction
    }

    let driver: Driver<InnerPresenter>

    init(driver: Driver<InnerPresenter>) {
        self.driver = driver
    }

    func handle(action: InnerPresenter.HandledAction) {

    }
}

final class InitialPresenter: DrivenPresenter {
    enum Event {
        case applicationLoaded
    }
    enum HandledAction {
        case someAction
    }

    private let innerActionSource = ActionSource<InnerPresenter.HandledAction>()

    let driver: Driver<InitialPresenter>

    init(driver: Driver<InitialPresenter>, inner: InnerPresenter) {
        self.driver = driver

        driver.submit(event: .applicationLoaded)

        inner.embed(actionSource: innerActionSource, receivingEvents: receive(event:))
    }

    func handle(action: InitialPresenter.HandledAction) {
        innerActionSource.perform(action: .someAction)
    }

    private func receive(event: InnerPresenter.Event) {

    }
}

final class InitialController: HyperViewController<InitialView>, DrivenController, PerformsNavigation {
    typealias PerformedAction = InitialPresenter.HandledAction
    typealias Event = InitialPresenter.Event

    enum NavigationRoute {
        case login
        case main(User)
        case admin(Admin)
    }

    let driver: Driver<InitialController>

    init(driver: Driver<InitialController>) {
        self.driver = driver

        super.init(initialState: InitialView.State())
    }

    func receive(event: Event) {
        switch event {
        case .applicationLoaded:
            driver.navigate(to: .login)
            driver.navigate(to: .main)
            driver.navigate(to: .admin)

            driver.perform(action: .someAction)
        }
    }
}

final class InitialView: HyperViewBase, HyperView {
    let outlets = InitialView.Outlets()

    init(actionPublisher: ActionPublisher<Action>) {
        super.init()
    }

    func apply(change: State.Change) {

    }

    func set(state: State) {
        
    }
}

extension InitialView {
    struct State: HyperViewState {


        enum Change {

        }
    }
    struct Outlets: HyperViewOutlets {
        init() { }
    }
    enum Action {

    }
}

print("Done")

//: [Next](@next)
