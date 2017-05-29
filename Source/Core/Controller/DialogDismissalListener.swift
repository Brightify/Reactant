//
//  DialogDismissalListener.swift
//  Reactant
//
//  Created by Filip Dolnik on 09.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

public protocol DialogDismissalListener {
    
    func dialogWillDismiss()
    
    func dialogDidDismiss()
}

extension DialogDismissalListener {

    public func dialogWillDismiss() { }

    public func dialogDidDismiss() { }
}
