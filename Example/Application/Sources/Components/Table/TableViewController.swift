//
//  TableViewController.swift
//  Reactant
//
//  Created by Matous Hybl on 3/24/17.
//  Copyright © 2017 Brightify s.r.o. All rights reserved.
//

import Reactant

class TableViewController: ControllerBase<Void, TableViewRootView> {

    struct Dependencies {
        let nameService: NameService
    }

    struct Reactions {
        let displayName: (String) -> Void
    }

    private let dependencies: Dependencies
    private let reactions: Reactions

    init(dependencies: Dependencies, reactions: Reactions) {
        self.dependencies = dependencies
        self.reactions = reactions
        super.init()
    }

    override func update() {
        rootView.componentState = .items(dependencies.nameService.names())
    }

    override func act(on action: TableViewRootView.ActionType) {
        switch action {
        case .selected(let name):
            reactions.displayName(name)
        default:
            break
        }
    }
}
