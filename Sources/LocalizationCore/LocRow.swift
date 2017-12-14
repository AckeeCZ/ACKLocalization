//
//  LocRow.swift
//  LocalizationCore
//
//  Created by Jakub Olejník on 14/12/2017.
//

import Foundation

struct LocRow {
    let key: String
    let value: String
    
    var localizableRow: String { return "\"" + key + "\" = \"" + value + "\";" } 
}
