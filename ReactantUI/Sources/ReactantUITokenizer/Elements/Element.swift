public struct Element {
    static let elementMapping: [String: View.Type] = [
        "Component": ComponentReference.self,
        "Container": Container.self,
        "Label": Label.self,
        "TextField": TextField.self,
        "Button": Button.self,
        "ImageView": ImageView.self,
        "ScrollView": ScrollView.self,
        "StackView": StackView.self,
    ]

    public static let elementToUIKitNameMapping: [String: String] = [
        "Component": "UIView",
        "Container": "UIView",
        "Label": "UILabel",
        "TextField": "UITextField",
        "Button": "UIButton",
        "ImageView": "UIImageView",
        "ScrollView": "UIScrollView",
        "StackView": "UIStackView",
        ]
}
