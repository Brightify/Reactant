import Foundation

public enum SystemFontWeight: String {
    public static let allValues: [SystemFontWeight] = [
        .ultralight, .thin, .light, .regular, .medium, .semibold, .bold, .heavy, .black
    ]

    case ultralight
    case thin
    case light
    case regular
    case medium
    case semibold
    case bold
    case heavy
    case black

    public var name: String {
        switch self {
        case .ultralight:
            return "UIFontWeightUltraLight"
        case .thin:
            return "UIFontWeightThin"
        case .light:
            return "UIFontWeightLight"
        case .regular:
            return "UIFontWeightRegular"
        case .medium:
            return "UIFontWeightMedium"
        case .semibold:
            return "UIFontWeightSemibold"
        case .bold:
            return "UIFontWeightBold"
        case .heavy:
            return "UIFontWeightHeavy"
        case .black:
            return "UIFontWeightBlack"
        }
    }

    #if ReactantRuntime
    public var value: CGFloat {
        switch self {
        case .ultralight:
            return UIFontWeightUltraLight
        case .thin:
            return UIFontWeightThin
        case .light:
            return UIFontWeightLight
        case .regular:
            return UIFontWeightRegular
        case .medium:
            return UIFontWeightMedium
        case .semibold:
            return UIFontWeightSemibold
        case .bold:
            return UIFontWeightBold
        case .heavy:
            return UIFontWeightHeavy
        case .black:
            return UIFontWeightBlack
        }
    }
    #endif
}
