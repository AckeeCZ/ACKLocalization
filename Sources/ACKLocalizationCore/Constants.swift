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
    
    /// Prefix that defines that localization key holds sources item
    public static let sourcesKeyPrefix = "src"
    
    /// Regex pattern for suffix of the plural translations
    public static let pluralPattern = #"^([\w.]+)?##\{([\w]+)?\}$"#
}
