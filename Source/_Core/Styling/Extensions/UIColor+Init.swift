//
//  UIColor+Init.swift
//  Reactant
//
//  Created by Filip Dolnik on 16.10.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

#if canImport(UIKit)
import UIKit

extension UIColor {
    
    /**
     * Parses passed hex string and returns corresponding UIColor.
     * - parameter hex: string consisting of hex color, including hash symbol - accepted formats: "#RRGGBB" and "#RRGGBBAA"
     * - WARNING: This is not a failable **init** (i.e. it doesn't return nil if it fails to parse the passed string, instead it crashes the app) and therefore is NOT recommended for parsing colors received from back-end.
     */
    public convenience init(hex: String) {
        let hexNumber = String(hex.dropFirst())
        let length = hexNumber.count
        guard length == 6 || length == 8 else {
            preconditionFailure("Hex string \(hex) has to be in format #RRGGBB or #RRGGBBAA !")
        }
        
        if let hexValue = UInt(hexNumber, radix: 16) {
            if length == 6 {
                self.init(rgb: hexValue)
            } else {
                self.init(rgba: hexValue)
            }
        } else {
            preconditionFailure("Hex string \(hex) could not be parsed!")
        }
    }

    /**
     * Parses passed (Red, Green, Blue) UInt and returns corresponding UIColor, alpha is 1.
     * - parameter rgba: UInt of a color - (e.g. 0x33F100)
     * - WARNING: Passing in negative number or number higher than 0xFFFFFF is undefined behavior.
     */
    public convenience init(rgb: UInt) {
        if rgb > 0xFFFFFF {
            print("WARNING: RGB color is greater than the value of white (0xFFFFFF) which is probably developer error.")
        }
        self.init(rgba: (rgb << 8) + 0xFF)
    }

    /**
     * Parses passed (Red, Green, Blue, Alpha) UInt and returns corresponding UIColor.
     * - parameter rgba: UInt of a color - (e.g. 0x33F100EE)
     * - WARNING: Passing in negative number or number higher than 0xFFFFFFFF is undefined behavior.
     */
    public convenience init(rgba: UInt) {
        let red = CGFloat((rgba & 0xFF000000) >> 24) / 255.0
        let green = CGFloat((rgba & 0xFF0000) >> 16) / 255.0
        let blue = CGFloat((rgba & 0xFF00) >> 8) / 255.0
        let alpha = CGFloat(rgba & 0xFF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
#endif
