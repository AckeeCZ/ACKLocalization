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
    
    var localizableRow: String { return "\"" + key + "\" = \"" + normalizedValue + "\";" }
    
    private var normalizedValue: String {
        return value
            .replacingOccurrences(of: "\"", with: "\\\"")
            .replacingOccurrences(of: "\n", with: "\\n")
            .replacingOccurrences(of: "\\u", with: "\\U")
            .replacingOccurrences(of: "%s", with: "%@")
            .replacingOccurrences(of: "%", with: "%%")
            .replacingOccurrences(of: "%%@", with: "%@")
            .replacingOccurrences(of: "%%d", with: "%d")
            .replacingOccurrences(of: "%%s", with: "%s")
            .replacingOccurrences(of: "%%f", with: "%f")
    }
}
