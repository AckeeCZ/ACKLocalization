//
//  PluralRuleWrapper.swift
//  
//
//  Created by Lukáš Hromadník on 07/07/2020.
//

import Foundation

/// Custom wrapper around plural rule to have nice way how to create the stringsDict
/// without a need to create dynamic dictionaries
struct PluralRuleWrapper {
    /// Array of plural rules (plural rule = one | zero | two ...)
    let translations: [PluralRule]
}

extension PluralRuleWrapper: Codable {
    private enum Constants {
        static let stringFormatSpecifier = "%s"
    }
    
    func encode(to encoder: Encoder) throws {
        // Since the stringDict is completely dynamic
        // we cannot use some predefined `struct` to encapsulate the data.
        // We need to use `CustomKey` that can take any string as a key.
        var container = encoder.container(keyedBy: CustomKey.self)
        
        // If the plural contains string format specifier, then use the positional arguments.
        let containsStringSpecifier: Bool = translations.contains(where: {
            $0.value.lowercased().contains(Constants.stringFormatSpecifier)
        } )
        let formatKey = containsStringSpecifier ? "%1$#@inner@" : "%#@inner@"
        
        var items = [
            // Mandatory key and the only option
            "NSStringFormatSpecTypeKey": "NSStringPluralRuleType",
            "NSStringFormatValueTypeKey": "d"
        ]

        translations.forEach {
            items[$0.key.rawValue] = $0.value.replacingOccurrences(
                of: Constants.stringFormatSpecifier,
                with: "%2$@"
            )
        }
        
        // StringsDicts use variables by default.
        // We need to specify the variable that is then
        // replaced by the plural rule.
        // In this case the variable is `inner` and it's hardcoded.
        try container.encode(formatKey, forKey: .init(stringValue: "NSStringLocalizedFormatKey"))
        try container.encode(items, forKey: .init(stringValue: "inner"))
    }
}
