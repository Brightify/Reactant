//
//  UIFont+System.swift
//  Reactant
//
//  Created by Matouš Hýbl on 09/02/2018.
//

#if canImport(UIKit)
import UIKit

public extension UIFont {
    @available(iOS 8.2, *)
    public enum System {
        case ultraLight
        case thin
        case light
        case regular
        case medium
        case semibold
        case bold
        case heavy
        case black
        
        private var weight: CGFloat {
            switch self {
            case .ultraLight:
                return UIFont.Weight.ultraLight.rawValue
            case .thin:
                return UIFont.Weight.thin.rawValue
            case .light:
                return UIFont.Weight.light.rawValue
            case .regular:
                return UIFont.Weight.regular.rawValue
            case .medium:
                return UIFont.Weight.medium.rawValue
            case .semibold:
                return UIFont.Weight.semibold.rawValue
            case .bold:
                return UIFont.Weight.bold.rawValue
            case .heavy:
                return UIFont.Weight.heavy.rawValue
            case .black:
                return UIFont.Weight.black.rawValue
            }
        }
        
        public subscript(size: CGFloat) -> UIFont {
            return font(size: size)
        }
        
        public func font(size: CGFloat) -> UIFont {
            return UIFont.systemFont(ofSize: size, weight: UIFont.Weight(rawValue: weight))
        }
    }
}

public extension UIFont {
    public func smallCapitals() -> UIFont {
        let settings = [
            [UIFontDescriptor.FeatureKey.featureIdentifier: kLowerCaseType,
             UIFontDescriptor.FeatureKey.typeIdentifier: kLowerCaseSmallCapsSelector],
            [UIFontDescriptor.FeatureKey.featureIdentifier: kNumberCaseType,
             UIFontDescriptor.FeatureKey.typeIdentifier: kUpperCaseNumbersSelector]]
        let attributes: [UIFontDescriptor.AttributeName: Any] = [UIFontDescriptor.AttributeName.featureSettings: settings, UIFontDescriptor.AttributeName.name: fontName]
        return UIFont(descriptor: UIFontDescriptor(fontAttributes: attributes), size: pointSize)
    }
}

public extension UIFont {
    public func with(traits: UIFontDescriptor.SymbolicTraits...) -> UIFont {
        let descriptor = fontDescriptor.withSymbolicTraits(UIFontDescriptor.SymbolicTraits(traits))!
        return UIFont(descriptor: descriptor, size: 0)
    }
    
    public func italic() -> UIFont {
        return with(traits: .traitItalic)
    }
    
}
#endif
