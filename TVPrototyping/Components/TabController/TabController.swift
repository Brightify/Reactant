//
//  TabController.swift
//  TVPrototyping
//
//  Created by Matous Hybl on 03/11/2017.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Reactant

class TabController: UITabBarController {

    private let buttonController = ButtonController()
    private let tableController = TableViewController()
    private let collectionController = CollectionViewController()
    private let mapController = MapController()

    override func viewDidLoad() {
        setViewControllers([buttonController, tableController, collectionController, mapController], animated: false)
    }
}
