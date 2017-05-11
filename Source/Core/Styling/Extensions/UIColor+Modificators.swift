//
//  UIColor+Modificators.swift
//  Lipstick
//
//  Created by Filip Dolnik on 16.10.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

#if os(iOS)
import UIKit

extension UIColor {

    /// Increases color's brightness.
    public func lighter(by percent: CGFloat) -> UIColor {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        if getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
            brightness = adjust(brightness, by: percent)
            return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
        } else {
            return self
        }
    }
    
    /// Reduces color's brightness.
    public func darker(by percent: CGFloat) -> UIColor {
        return lighter(by: -percent)
    }
    
    /// Increases color's saturation.
    public func saturated(by percent: CGFloat) -> UIColor {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        if getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
            saturation = adjust(saturation, by: percent)
            return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
        } else {
            return self
        }
    }
    
    /// Reduces color's saturation.
    public func desaturated(by percent: CGFloat) -> UIColor {
        return saturated(by: -percent)
    }
    
    /// Increases color's alpha.
    public func fadedIn(by percent: CGFloat) -> UIColor {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        if getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
            alpha = adjust(alpha, by: percent)
            return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
        } else {
            return self
        }
    }
    
    /// Reduces color's alpha.
    public func fadedOut(by percent: CGFloat) -> UIColor {
        return fadedIn(by: -percent)
    }
    
    private func adjust(_ value: CGFloat, by amount: CGFloat) -> CGFloat {
        return min(max(0, value + value * amount), 1)
    }
}
#endif
