//
//  AppModule.swift
//  Reactant
//
//  Created by Matous Hybl on 3/24/17.
//  Copyright © 2017 Brightify s.r.o. All rights reserved.
//

import Foundation

class AppModule: DependencyModule {

    var nameService: NameService {
        return NameService()
    }
    
}
