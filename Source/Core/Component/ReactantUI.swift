public protocol ReactantUI: class {
    var __rui: ReactantUIContainer { get }
}

public protocol ReactantUIContainer: class {
    var xmlPath: String { get }

    var typeName: String { get }

    func setupReactantUI()

    static func destroyReactantUI(target: View)
}
