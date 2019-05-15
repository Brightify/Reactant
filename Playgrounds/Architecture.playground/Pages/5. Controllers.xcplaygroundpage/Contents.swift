//: [Previous](@previous)
/*:

 # 5. Controllers

 Controller takes care of handling events from presenters and propagating those to `View` and navigation.

 Controller decides when to call navigation methods directly, as a result of an action from view.

 Controller is never allowed to communicate with Service Layer or Presenter directly.

 Controller can only communicate with:

 * Presenters - bidirectional
    * Presenter -> Controller = receiving event from presenter
    * Controller -> Presenter = performing an action that presenter handles

 * Wireframes - unidirectional
    * Controller -> Wireframe = performing a navigation action that wireframe handles

 * View - bidirectional
    * Controller -> View = modifying the view's state
    * Controller -> View = submitting changes to the view's state (more granular modification of the state)
    * View -> Controller = receiving a view action from the view (e.g. button tap, row select, text field change)
 */

import UIKit
import Hyperdrive

final class ProfileListController: UIViewController, DrivenController {

    var _driver: Driver<ProfileListController>!
    var driver: Driver<ProfileListController> {
        return _driver
    }

    typealias PerformedAction = Void

    func receive(event: Void) {

    }
}


//: [Presenters](@next)
