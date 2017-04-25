//
//  PreviewListController.swift
//  Pods
//
//  Created by Tadeas Kriz on 4/25/17.
//
//

import Reactant

final class PreviewListController: ControllerBase<Void, PreviewListRootView> {
    struct Dependencies {
        let manager: ReactantLiveUIManager
    }
    struct Reactions {
        let preview: (String) -> Void
        let close: () -> Void
    }

    private let dependencies: Dependencies
    private let reactions: Reactions

    private let closeButton = UIBarButtonItem(title: "Close", style: .done)

    init(dependencies: Dependencies, reactions: Reactions) {
        self.dependencies = dependencies
        self.reactions = reactions

        super.init(title: "Select view to preview")
    }

    override func afterInit() {
        navigationItem.leftBarButtonItem = closeButton
        closeButton.rx.tap
            .subscribe(onNext: reactions.close)
            .addDisposableTo(lifetimeDisposeBag)
    }

    override func update() {
        let items = dependencies.manager.allRegisteredDefinitionNames
        rootView.componentState = .items(items)
    }

    override func act(on action: PlainTableViewAction<PreviewListCell>) {
        switch action {
        case .refresh:
            dependencies.manager.reloadFiles()
            invalidate()
        case .selected(let path):
            reactions.preview(path)
        case .rowAction:
            break
        }
    }
}
