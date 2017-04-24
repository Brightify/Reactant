import Foundation

public enum VisualEffect {
    case blur(BlurEffect)
    case vibrancy(BlurEffect)
}

public enum BlurEffect: String {
    case extraLight
    case light
    case dark
    case prominent
    case regular
}
