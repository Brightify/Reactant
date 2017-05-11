import Cocoa
import RxSwift

class ScrollViewContainer: ViewBase<Void, Void> {
    override var isFlipped: Bool {
        return _flipped
    }
    private let _flipped: Bool

    init(flipped: Bool) {
        self._flipped = flipped
        super.init()
    }
}

open class ScrollView<VIEW: View>: ViewBase<VIEW.StateType, VIEW.ActionType> where VIEW: Component {
    open override var action: Observable<VIEW.ActionType> {
        return contentView.action
    }

    public let contentView: VIEW
    public let scrollView = NSScrollView()
    private let container: ScrollViewContainer

    public init(contentView: VIEW = VIEW.init(), flipped: Bool = true) {
        self.contentView = contentView
        container = ScrollViewContainer(flipped: flipped)

        super.init()
    }

    open override func update() {
        contentView.componentState = componentState
    }

    open override func loadView() {
        children(
            scrollView
        )

        scrollView.documentView = container

        container.children(
            contentView
        )
        
        scrollView.hasVerticalScroller = true
    }

    open override func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        container.snp.makeConstraints { make in
            make.left.equalTo(scrollView.contentView)
            make.top.equalTo(scrollView.contentView)
            make.right.equalTo(scrollView.contentView)
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
