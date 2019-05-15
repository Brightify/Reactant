//
//  UIColor+Modificators.swift
//  Reactant
//
//  Created by Filip Dolnik on 16.10.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

#if canImport(UIKit)
import UIKit

extension UIColor {

    /**
     * Increases color's brightness.
     * - parameter percent: determines by how much will the color get lighter
     * Expected values between 0.0-1.0
     */
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

    /**
     * Reduces color's brightness.
     * - parameter percent: determines by how much will the color get darker
     * Expected values between 0.0-1.0
     */
    public func darker(by percent: CGFloat) -> UIColor {
        return lighter(by: -percent)
    }

    /**
     * Increases color's saturation.
     * - parameter percent: determines by how much will the color get saturated
     * Expected values between 0.0-1.0
     */
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

    /**
     * Reduces color's saturation.
     * - parameter percent: determines by how much will the color get desaturated
     * Expected values between 0.0-1.0
     */
    public func desaturated(by percent: CGFloat) -> UIColor {
        return saturated(by: -percent)
    }

    /**
     * Increases color's alpha.
     * - parameter percent: determines by how much will the color's alpha increase
     * Expected values between 0.0-1.0
     */
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

    /**
     * Reduces color's alpha.
     * - parameter percent: determines by how much will the color's alpha decrease
     * Expected values between 0.0-1.0
     */
    public func fadedOut(by percent: CGFloat) -> UIColor {
        return fadedIn(by: -percent)
    }
    
    private func adjust(_ value: CGFloat, by amount: CGFloat) -> CGFloat {
        return min(max(0, value + value * amount), 1)
    }
}
#endif
