import Reactant

final class LiveUIErrorMessageItem: ViewBase<(file: String, message: String), Void> {
    private let message = UILabel()
    private let path = UILabel()

    override func update() {
        message.text = componentState.message
        path.text = "in: \(componentState.file)"
    }

    override func loadView() {
        children(
            message,
            path
        )

        Styles.message(label: message)
        Styles.path(label: path)
    }

    override func setupConstraints() {
        message.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalToSuperview()
        }

        path.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(10)
            make.trailing.equalToSuperview()
            make.top.equalTo(message.snp.bottom).offset(8)
            make.bottom.equalToSuperview()
        }
    }
}

extension LiveUIErrorMessageItem {
    fileprivate struct Styles {
        static func path(label: UILabel) {
            label.textColor = .white
            label.numberOfLines = 0
            label.font = UIFont.monospacedDigitSystemFont(ofSize: 14, weight: UIFontWeightRegular)
        }

        static func message(label: UILabel) {
            label.textColor = .white
            label.numberOfLines = 0
            label.font = UIFont.boldSystemFont(ofSize: 16)
        }
    }
}
