//
//  LocRow.swift
//  
//
//  Created by Jakub Olejník on 12/12/2019.
//

import Foundation

/// Struct representing single `Localizable.strings` row
public struct LocRow {
    /// Key of current row
    public let key: String
    
    /// Original value from spreadsheet
    public let value: String
    
    /// Representation that can be used as row in strings file
    public var localizableRow: String { return "\"" + normalizedKey + "\" = \"" + normalizedValue + "\";" }
    
    // MARK: - Initializers
    
    public init(key: String, value: String) {
        self.key = key
        self.value = value
    }
    
    // MARK: - Private helpers

    /// Key with replaced quotes
    private var normalizedKey: String {
        return key
            .replacingOccurrences(of: "\"", with: "\\\"")
    }
    
    /// Value with replaced placeholder arguments
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
            .replacingOccurrences(of: "%%.([0-9])f", with: "%.$1f", options: .regularExpression)
            .replacingOccurrences(of: "%%i", with: "%i")
            .replacingPositionedArgs(separator: " ")
            .replacingPositionedArgs(separator: "\n")
    }
}

private extension String {
    /// Replaces positioned arguments by given separator
    func replacingPositionedArgs(separator: String) -> String {
        return components(separatedBy: separator)
        .map {
            guard $0.contains("%") && ($0.contains("$s") || $0.contains("$d") || $0.contains("$f") || $0.contains("$@")) else { return $0 }

            return $0.replacingOccurrences(of: "%%", with: "%")
                .replacingOccurrences(of: "$s", with: "$@")
        }
        .joined(separator: separator)
    }
}
