//: [Previous](@previous)
/*:
 # 4. Presenters

 Presenter takes care of communication between the view layer, services and other presenters.

 Presenter knows nothing about the UI layer and thus can be independently unit tested.

 Presenter provides events which are then received by the Controller (view layer).

 Presenter doesn't care about navigation.

 Presenter can modify the model.

 Presenter subscribes to model changes, converting them into events (see above).

 Presenter can have inner presenters if needed and can communicate with them directly.

 Presenter has to use indirect communication via model changes with other presenters that aren't direct children of the presenter (other screens aren't children!).

 Presenter should have no inner state (except for model and wiring).

 Presenter has to ensure that it communicates with the Controller on the main queue.

 */

import Hyperdrive

/*:
 Let's start with creating a simple presenter. We'll call it `MapPresenter` and it'll take care of selecting a location on a map.

 Every presenter has to implement protocol `DrivenPresenter`.
 */
final class SimplePresenter: DrivenPresenter {
//: Each presenter declares its `Event` type for events propagated to the controller ..
    enum Event {
        case locationChanged(latitude: Double, longitude: Double)
    }
//: .. and its `HandledAction` type specifying what actions from a controller it can handle.
    enum HandledAction {
        case saveLocation(latitude: Double, longitude: Double)
    }

//: Driver is important for communication with the controller and for memory management.
    let driver: Driver<SimplePresenter>

    init(driver: Driver<SimplePresenter>) {
        self.driver = driver
    }

//: The `handle(action:)` method is required to take care of controller actions.
    func handle(action: SimplePresenter.HandledAction) {
        switch action {
        case .saveLocation(let latitude, let longitude):
            // ... saves location to the model
            break
        }
    }

//: This method would be called from outside of this presenter.
    func locationUpdated(latitude: Double, longitude: Double) {
        driver.submit(event: .locationChanged(latitude: latitude, longitude: longitude))
    }
}

//: [Next](@next)
