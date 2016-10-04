//
//  Transformations.swift
//  Reactant
//
//  Created by Tadeáš Kříž on 09/09/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import SwiftKit
import SwiftyJSON

public struct Transformations {

    public static let int = IntTransformation()
    public static let string = StringTransformation()
    public static let url = NSURLTransformation()
    public static let bool = BoolTransformation()
    public static let double = DoubleTransformation()
    public static let date = ISO8601DateTransformation()

}
