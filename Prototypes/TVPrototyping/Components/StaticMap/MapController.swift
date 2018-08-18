//
//  MapController.swift
//  TVPrototyping
//
//  Created by Matous Hybl on 03/11/2017.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Reactant
import MapKit

final class MapController: ControllerBase<Void, MapRootView> {

    override func afterInit() {
        tabBarItem = UITabBarItem(title: "StaticMap", image: nil, tag: 0)
    }
}

final class MapRootView: ViewBase<Void, Void>, RootView {

    private let map = StaticMap()

    override func update() {
        map.componentState = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(40.0, 14.0), 10000, 10000)
    }

    override func loadView() {
        children(map)

        map.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
