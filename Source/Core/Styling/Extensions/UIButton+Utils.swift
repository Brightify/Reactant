//
//  UIButton+Utils.swift
//  Lipstick
//
//  Created by Tadeas Kriz on 31/03/16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import UIKit

extension UIButton {
    
    public convenience init(title: String) {
        self.init()
        
        setTitle(title, for: UIControlState())
    }
}

extension UIButton {
    
    public func setBackgroundColor(_ color: UIColor, for state: UIControlState) {
        let rectangle = CGRect(size: CGSize(1));
        UIGraphicsBeginImageContext(rectangle.size);
        
        let context = UIGraphicsGetCurrentContext();
        context?.setFillColor(color.cgColor);
        context?.fill(rectangle);
        
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        setBackgroundImage(image!, for: state)
    }
}
