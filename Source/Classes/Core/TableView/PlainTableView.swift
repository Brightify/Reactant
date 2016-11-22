//
//  PlainTableViewswift
//  Reactant
//
//  Created by Filip Dolnik on 16.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import UIKit

public typealias PlainTableView<CELL: UIView> = SimpleTableView<NoTableViewHeaderFooterMarker, CELL, NoTableViewHeaderFooterMarker> where CELL: Component
