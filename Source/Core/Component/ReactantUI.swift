public protocol ReactantUI: class {
    var __rui: ReactantUIContainer { get }
}

public protocol ReactantUIContainer: class {
    var xmlPath: String { get }

    var typeName: String { get }

    func setupReactantUI()

    func updateReactantUI()

    static func destroyReactantUI(target: Platform.View)
}

internal extension Platform.View {
    func tryUpdateReactantUI() {
        guard self is ReactantUI else {
            return
        }

        updateReactantUIRecursive()
    }

    private func updateReactantUIRecursive() {
        if let reactantUi = self as? ReactantUI {
            reactantUi.__rui.updateReactantUI()
        }

        for child in subviews {
            child.updateReactantUIRecursive()
        }
    }
}
