/*:

 # 1. View

 View is defined solely in an XML file. A Swift implementation is generated automatically.

 View supports `{{ x }}`  for properties which generates a `State` structure.

 View supports `action:x` attributes for wiring actions.

 View has Outlets structure to expose its children to its `Controller`.

 View has Layout structure to expose constraints to its `Controller`.

 Example:

 ```xml
 <?xml version="1.0" encoding="UTF-8" ?>
 <CustomView changes="applying|tracking|none">
    <TextField text="{{ message }}" action:text="messageChanged" />
    <Button text="Sign in" action:tap="signInTapped" />
    <Label outlet="title" />
 </CustomView>
 ```
 */

import UIKit
import Hyperdrive

final class CustomView: UIView, HyperView {
    private let textField1Delegate: Hyperdrive.TextFieldActionDelegate
    private let button2Delegate: Hyperdrive.ButtonActionDelegate

    private let textField1 = UITextField()
    private let button2 = UIButton()
    private let label3: UILabel

    private let actionPublisher: ActionPublisher<Action>

    let outlets = CustomView.Outlets()
 
    init(actionPublisher: ActionPublisher<Action>) {
        self.actionPublisher = actionPublisher

        self.textField1Delegate = Hyperdrive.TextFieldActionDelegate(
            onTextChanged: actionPublisher.publisher(Action.messageChanged))

        self.button2Delegate = Hyperdrive.ButtonActionDelegate(
            onTapped: actionPublisher.publisher(Action.signInTapped))

        label3 = outlets.title

        super.init(frame: .zero)

        loadView()
        setupConstraints()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError("Not supported!") }

    func set(state: CustomView.State) {
        textField1.text = state.message

    }

    func apply(change: CustomView.State.Change) {
        switch change {
        case .changeMessage(let message):
            textField1.text = message
        }
    }

    private func loadView() {
        addSubview(textField1)
        addSubview(button2)
        addSubview(label3)

        // First version might use RxSwift, we should drop it later though
        // in favor of implementing delegates and using those in this view.
        textField1Delegate.bind(to: textField1)
        button2Delegate.bind(to: button2)
    }

    private func setupConstraints() {
        // ...
    }
}

extension CustomView {
    struct Outlets: HyperViewOutlets {
        let title = UILabel()

        init() {

        }
    }
    struct State: HyperViewState {
        private var changes: [Change]? = nil

        var message: String? {
            didSet {
                changes?.append(.changeMessage(message))
            }
        }

        mutating func mutateRecordingChanges(mutation: (inout State) -> Void) -> [Change] {
            var mutableState = self
            mutableState.changes = []

            mutation(&mutableState)

            let changes = mutableState.changes
            mutableState.changes = nil

            self = mutableState

            return changes ?? []
        }

        mutating func apply(change: CustomView.State.Change) {
            switch change {
            case .changeMessage(let message):
                self.message = message
            }
        }

        enum Change {
            case changeMessage(String?)
        }
    }

    enum Action {
        case messageChanged(String?)
        case signInTapped
    }
}

/*:

 ```
 <TimelineView>
     <TimelineListView external="list" />
     <TimelineGridView external="grid" />
 </TimelineView>
 ```

 */

//class TimelineListView { }
//class TimelineGridView { }
//
//class TimelineListControler: HyperViewController<TimlineListView> {
//
//}
//
//class TimelineView {
//    private var list = ExternalView<TimelineListView>()
//    private var grid = ExternalView<TimelineGridView>()
//
//    init(list: TimelineListView, grid: TimelineGridView) {
//        self.list = list
//        self.grid = grid
//    }
//
//    required init(actionPublisher: ActionPublisher<Action>) {
//
//    }
//
//    func bind(list: TimelineListView,
//              grid: TimelineGridView) {
//
//        self.list.view = list
//        self.grid.view = grid
//    }
//}
//
//class TimelineControler: UIViewController {
//
//    init(list: TimelineListControler)
//
//    override func loadView() {
//        view = TimelineView(list: list.view, grid: grid.view)
//    }
//
//}

//class CustomView: UIView, HyperView {
//    private let textField1Delegate: Hyperdrive.TextFieldActionDelegate
//    private let button2Delegate: Hyperdrive.ButtonActionDelegate
//
//    private let textField1 = UITextField()
//    private let button2 = UIButton()
//
//    private let actionPublisher: ActionPublisher<Action>
//
//    init(actionPublisher: ActionPublisher<Action>) {
//        self.actionPublisher = actionPublisher
//
//        self.textField1Delegate = Hyperdrive.TextFieldActionDelegate(
//            onTextChanged: actionPublisher.publisher(Action.messageChanged))
//
//        self.button2Delegate = Hyperdrive.ButtonActionDelegate(
//            onTapped: actionPublisher.publisher(Action.signInTapped))
//    }
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//    }
//
//
//
//    private func loadView() {
//        addSubview(textField1)
//        addSubview(button2)
//
//        // First version might use RxSwift, we should drop it later though
//        // in favor of implementing delegates and using those in this view.
//        textField1Delegate.bind(to: textField1)
//        button2Delegate.bind(to: button2)
//    }
//
//    private func setupConstraints() {
//        // ...
//    }
//}
//
//extension CustomView {
//    struct State {
//        var message: String
//    }
//
//    enum Action {
//        case messageChanged(String?)
//        case signInTapped
//    }
//}

//class HyperdriveInterface<T: HyperView> {
//    func create<T: HyperView>(_ type: T.self)
//}


//: [Next](@next)
