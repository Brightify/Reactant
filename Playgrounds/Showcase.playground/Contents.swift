//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport
import Hyperdrive

Configuration.global.style.controllerRoot = {
    $0.backgroundColor = UIColor.white
}

class MyRootView: ViewBase<String, Void>, RootView {
    private let label = UILabel()

    var edgesForExtendedLayout: UIRectEdge {
        return .bottom
    }

    override func update() {
        label.text = componentState
    }

    override func loadView() {
        children(
            label
        )
    }

    override func setupConstraints() {
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}

class MyViewController : ControllerBase<Void, MyRootView> {
    override func afterInit() {
        rootView.componentState = "Hello world!"
    }
}

// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MyViewController()

