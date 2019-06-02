//
//  Attribute.swift
//  Reactant
//
//  Created by Tadeas Kriz on 5/2/17.
//  Copyright © 2017 Brightify. All rights reserved.
//

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif


/// Enum which represents NS attributes for NSAttributedString (like NSStrokeColorAttributeName). Each case has value and assigned name.
public enum Attribute {
    #if canImport(UIKit)
    case font(UIFont?)
    #elseif canImport(AppKit)
    case font(NSFont?)
    #endif
    case paragraphStyle(NSParagraphStyle)
    case foregroundColor(UIColor)
    case backgroundColor(UIColor)
    case ligature(Int)
    case kern(Float)
    case striketroughStyle(NSUnderlineStyle)
    case underlineStyle(NSUnderlineStyle)
    case strokeColor(UIColor)
    case strokeWidth(Float)
    case shadow(NSShadow)
    case textEffect(String)
    case attachment(NSTextAttachment)
    case linkURL(URL)
    case link(String)
    case baselineOffset(Float)
    case underlineColor(UIColor)
    case strikethroughColor(UIColor)
    case obliqueness(Float)
    case expansion(Float)
    case writingDirection(NSWritingDirection)
    case verticalGlyphForm(Int)

    public var key: NSAttributedString.Key {
        switch self {
        case .font:
            return NSAttributedString.Key.font
        case .paragraphStyle:
            return NSAttributedString.Key.paragraphStyle
        case .foregroundColor:
            return NSAttributedString.Key.foregroundColor
        case .backgroundColor:
            return NSAttributedString.Key.backgroundColor
        case .ligature:
            return NSAttributedString.Key.ligature
        case .kern:
            return NSAttributedString.Key.kern
        case .striketroughStyle:
            return NSAttributedString.Key.strikethroughStyle
        case .underlineStyle:
            return NSAttributedString.Key.underlineStyle
        case .strokeColor:
            return NSAttributedString.Key.strokeColor
        case .strokeWidth:
            return NSAttributedString.Key.strokeWidth
        case .shadow:
            return NSAttributedString.Key.shadow
        case .textEffect:
            return NSAttributedString.Key.textEffect
        case .attachment:
            return NSAttributedString.Key.attachment
        case .linkURL:
            return NSAttributedString.Key.link
        case .link:
            return NSAttributedString.Key.link
        case .baselineOffset:
            return NSAttributedString.Key.baselineOffset
        case .underlineColor:
            return NSAttributedString.Key.underlineColor
        case .strikethroughColor:
            return NSAttributedString.Key.strikethroughColor
        case .obliqueness:
            return NSAttributedString.Key.obliqueness
        case .expansion:
            return NSAttributedString.Key.expansion
        case .writingDirection:
            return NSAttributedString.Key.writingDirection
        case .verticalGlyphForm:
            return NSAttributedString.Key.verticalGlyphForm
        }
    }

    @available(*, deprecated, message: "Attribute name is deprecated, use `key` instead.")
    public var name: String {
        return key.rawValue
    }

    public var value: AnyObject? {
        switch self {
        case .font(let font):
            return font
        case .paragraphStyle(let style):
            return style
        case .foregroundColor(let color):
            return color
        case .backgroundColor(let color):
            return color
        case .ligature(let ligature):
            return ligature as AnyObject
        case .kern(let kerning):
            return kerning as AnyObject
        case .striketroughStyle(let style):
            return style.rawValue as AnyObject
        case .underlineStyle(let style):
            return style.rawValue as AnyObject
        case .strokeColor(let color):
            return color
        case .strokeWidth(let width):
            return width as AnyObject
        case .shadow(let shadow):
            return shadow
        case .textEffect(let effect):
            return effect as AnyObject
        case .attachment(let attachment):
            return attachment
        case .linkURL(let url):
            return url as AnyObject
        case .link(let url):
            return url as AnyObject
        case .baselineOffset(let offset):
            return offset as AnyObject
        case .underlineColor(let color):
            return color
        case .strikethroughColor(let color):
            return color
        case .obliqueness(let obliqueness):
            return obliqueness as AnyObject
        case .expansion(let expansion):
            return expansion as AnyObject
        case .writingDirection(let direction):
            return direction.rawValue as AnyObject
        case .verticalGlyphForm(let form):
            return form as AnyObject
        }
    }
}

public extension Sequence where Iterator.Element == Attribute {

    /// Creates dictionary from sequence of attributes by merging them together. *key* is name of case and *value* the corresponding value.
    public func toDictionary() -> [NSAttributedString.Key: AnyObject] {
        var attributeDictionary: [NSAttributedString.Key: AnyObject] = [:]
        for attribute in self {
            attributeDictionary[attribute.key] = attribute.value
        }
        return attributeDictionary
    }
}
