//
//  UICollectionView+InitTest.swift
//  Reactant
//
//  Created by Filip Dolnik on 18.10.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import Quick
import Nimble
import Reactant

class UICollectionViewInitTest: QuickSpec {
    
    override func spec() {
        describe("UICollectionView init") {
            it("creates UICollectionView with zero CGRect") {
                let layout = UICollectionViewFlowLayout()
                let view = UICollectionView(collectionViewLayout: layout)
                
                expect(view.frame) == CGRect.zero
                expect(view.collectionViewLayout) == layout
            }
        }
    }
}
