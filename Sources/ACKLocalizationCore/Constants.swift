//
//  Constants.swift
//  
//
//  Created by Jakub Olejník on 12/12/2019.
//

import Foundation

/// Struct holding important constants used throughout the tool
public enum Constants {
    /// Prefix that defines that localization key holds plist item
    public static let plistKeyPrefix = "plist"
    
    /// Regex pattern for plural keys
    public static let pluralKeyPattern = "(zero|one|two|few|many|other)"
    
    /// Regex pattern for suffix of the plural translations
    public static let pluralPattern = #"\#\#\{\#(pluralKeyPattern)\}{1}$"#
}
