//
//  String+EmailValidationError.swift
//  Reactant
//
//  Created by Filip Dolnik on 10.02.17.
//  Copyright © 2017 Brightify. All rights reserved.
//

extension Rules.String {
    
    public enum EmailValidationError: Error {
        case empty
        case invalid
    }
}
