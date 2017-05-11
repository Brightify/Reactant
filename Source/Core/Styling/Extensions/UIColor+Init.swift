//
//  UIColor+Init.swift
//  Lipstick
//
//  Created by Filip Dolnik on 16.10.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

#if os(iOS)
import UIKit

extension UIColor {
    
    /// Accepted formats: "#RRGGBB" and "#RRGGBBAA".
    public convenience init(hex: String) {
        let hexNumber = String(hex.characters.dropFirst())
        let length = hexNumber.characters.count
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

    public convenience init(rgb: UInt) {
        if rgb > 0xFFFFFF {
            print("WARNING: RGB color is greater than the value of white (0xFFFFFF) which is probably developer error.")
        }
        self.init(rgba: (rgb << 8) + 0xFF)
    }
    
    public convenience init(rgba: UInt) {
        let red = CGFloat((rgba & 0xFF000000) >> 24) / 255.0
        let green = CGFloat((rgba & 0xFF0000) >> 16) / 255.0
        let blue = CGFloat((rgba & 0xFF00) >> 8) / 255.0
        let alpha = CGFloat(rgba & 0xFF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
#endif
