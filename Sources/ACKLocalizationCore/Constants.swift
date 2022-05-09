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
    
    /// Regex pattern for suffix of the plural translations
    public static let pluralPattern = #"^([\w.]+)?##\{([\w]+)?\}$"#
    
    /// Environment variable key for providing service account path
    public static let serviceAccountPath = "ACKLOCALIZATION_SERVICE_ACCOUNT_PATH"
    
    /// Environment variable key for providing API key
    public static let apiKey = "ACKLOCALIZATION_API_KEY"
}
