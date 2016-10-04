//
//  Transformations.swift
//  Reactant
//
//  Created by Tadeáš Kříž on 09/09/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import SwiftKit
import SwiftyJSON

open struct Transformations {

    open static let int = IntTransformation()
    open static let string = StringTransformation()
    open static let url = NSURLTransformation()
    open static let bool = BoolTransformation()
    open static let double = DoubleTransformation()
    open static let date = ISO8601DateTransformation()

}
