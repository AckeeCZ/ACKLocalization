//
//  LocRow.swift
//  
//
//  Created by Jakub Olejník on 12/12/2019.
//

import Foundation

public struct LocRow {
    public let key: String
    public let value: String
    
    public var localizableRow: String { return "\"" + key + "\" = \"" + normalizedValue + "\";" }
    
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
            .replacingOccurrences(of: "%%i", with: "%i")
            .replacingPositionedArgs(separator: " ")
            .replacingPositionedArgs(separator: "\n")
    }
}

private extension String {
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
