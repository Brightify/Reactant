import Reactant

final class LiveUIErrorMessage: ViewBase<[String: String], Void> {
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()

    override func update() {
        let state = componentState

        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for (index, item) in state.enumerated() {
            if index > 0 {
                let divider = UIView()
                Styles.divider(view: divider)
                stackView.addArrangedSubview(divider)
                divider.snp.makeConstraints { make in
                    make.height.equalTo(1)
                }
            }

            let itemView = LiveUIErrorMessageItem().with(state: (file: item.key, message: item.value))
            stackView.addArrangedSubview(itemView)
        }

        isHidden = state.isEmpty
    }

    override func loadView() {
        children(
            scrollView.children(
                stackView
            )
        )

        Styles.base(view: self)

        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.alignment = .fill
        stackView.spacing = 10
    }

    override func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 40, left: 20, bottom: 20, right: 20))
            make.width.equalToSuperview().inset(20)
        }
    }
}

extension LiveUIErrorMessage {
    fileprivate struct Styles {
        static func base(view: LiveUIErrorMessage) {
            view.backgroundColor = UIColor(red:0.800, green: 0.000, blue: 0.000, alpha:1)
        }

        static func divider(view: UIView) {
            view.backgroundColor = .white
        }

        static func stack(label: UILabel) {
            label.textColor = .white
            label.numberOfLines = 0
        }
    }
}
