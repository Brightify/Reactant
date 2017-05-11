//
//  UIImage+Utils.swift
//  Reactant
//
//  Created by Filip Dolnik on 21.02.17.
//  Copyright © 2017 Brightify. All rights reserved.
//

#if os(iOS)
import UIKit

extension UIImage {
    
    public var aspectRatio: CGFloat {
        return size.width / size.height
    }
}
#endif
