//
//  TableViewBase.swift
//  Reactant
//
//  Created by Filip Dolnik on 16.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import RxSwift
import RxCocoa

public typealias SimpleTableView<CELL: UIView> = TableView<NoTableViewHeaderFooterMarker, CELL, NoTableViewHeaderFooterMarker> where CELL: Component
