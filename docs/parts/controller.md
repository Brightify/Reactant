Controllers
===========

Controllers are `Components` in Reactant. Reactant was designed in a way that controller should never interact directly with any views it contains. Its only purpose is to somehow obtain state (from API, database etc.) and set this state to its `RootView` that takes care of displaying data. RootView is also responsible for notifying the controller about actions and the controller should respond to them accordingly i.e. by sending data to API, updating database etc.

Let's say that we have `MainController` and `MainRootView`.
```swift
final class MainViewController: ControllerBase<Void, MainRootView> {

    init() {
        // this needs to be called like this, because of a bug in Swift
        super.init(title: "Main")

        // set inital state of RootView
        rootView.componentState = Date()
    }

    override func update() {
        // do nothing since this controller has void state
    }

    // Act according to action from RootView
    override func act(on action: MainRootView.ActionType) {
        switch action {
        case .updateLabel:
            // when this action is sent from RootView, set new state to RootView's componentState
            rootView.componentState = Date()
            break
        // just a dummy action
        case .openTable:
            break
        }
    }
}

enum MainAction {
    case updateLabel
    case openTable
}

final class MainRootView: ViewBase<Date, MainAction>, RootView {

    // this property gather's producers of all actions that should be propagated to parent component
    override var actions: [Observable<MainAction>] {
        return [
            updateButton.rx.tap.rewrite(with: .updateLabel)
        ]
    }

    private let label = LabelView()
    private let updateButton = UIButton()

    private let dateFormatter = DateFormatter()

    override init() {
        super.init()

        dateFormatter.timeStyle = .long
    }

    override func update() {
        label.componentState = dateFormatter.string(from: componentState)
    }

    override func loadView() {
        children(
            label,
            updateButton
        )

        updateButton.setTitleColor(.white, for: .normal)
        updateButton.setTitle("Update", for: .normal)
        updateButton.backgroundColor = .blue
    }

    override func setupConstraints() {
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        updateButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview().offset(20)
            make.trailing.lessThanOrEqualToSuperview().inset(20)

            make.top.equalTo(label.snp.bottom).offset(20)
        }
    }
}
```

In this case RootView is responsible for displaying `Date` in a label. It also has a button, which whenever user clicks, invokes it's `rx.tap` event and this event is propagated to controller using `actions` property. Controller react's to such event using method `act`, so whenever `.updateLabel` value is passed to this method, new `Date` is set to RootView's `componentState`.

`ActionType` of RootView is in this case an `enum` `MainAction`. But it can be any other data type. Important advantage of using enums is that you can relatively easily add more action types, pass parameters to these actions and even **nest** enum values, which is very handy when propagating actions using `action` field of nested view.
