//
//  Configuration.swift
//  
//
//  Created by Jakub Olejník on 11/12/2019.
//

import Foundation

public typealias LanguageMapping = [String: String]

/// Object representing app parameters
///
/// Old variant, will be removed in future versions
public struct ConfigurationV1: Decodable {
    /// API key that will be used to comunicate with Google Sheets API
    ///
    /// Either `apiKey` or `serviceAccount` must be provided, if both are provided, then `serviceAccount` will be used
    public let apiKey: APIKey?
    
    /// Path to destination directory where generated strings files should be saved
    public let destinationDir: String
    
    /// Name of column that contains keys to be localized
    public let keyColumnName: String
    
    /// Mapping of language column names to app languages
    public let languageMapping: LanguageMapping
    
    /// Path to service account file that will be used to access spreadsheet
    ///
    /// Either `apiKey` or `serviceAccount` must be provided, if both are provided, then `serviceAccount` will be used
    public let serviceAccount: String?
    
    /// Identifier of spreadsheet that should be downloaded
    public let spreadsheetID: String
    
    /// Name of spreadsheet tab to be fetched
    ///
    /// If nothing is specified, we will use the first tab in spreadsheet
    public let spreadsheetTabName: String?
    
    /// Name of strings file that should be generated
    public let stringsFileName: String?
    
    /// Name of stringsDict file that should be generated
    public let stringsDictFileName: String?
    
    public init(apiKey: APIKey?, destinationDir: String, keyColumnName: String, languageMapping: LanguageMapping, serviceAccount: String?,
                spreadsheetID: String, spreadsheetTabName: String?, stringsFileName: String?, stringsDictFileName: String?) {
        self.apiKey = apiKey
        self.destinationDir = destinationDir
        self.keyColumnName = keyColumnName
        self.languageMapping = languageMapping
        self.serviceAccount = serviceAccount
        self.spreadsheetID = spreadsheetID
        self.spreadsheetTabName = spreadsheetTabName
        self.stringsFileName = stringsFileName
        self.stringsDictFileName = stringsDictFileName
    }
}

public typealias Configuration = ConfigurationV2

/// Object representing app parameters
public struct ConfigurationV2: Decodable {
    /// API key that will be used to comunicate with Google Sheets API
    ///
    /// Either `apiKey` or `serviceAccount` must be provided, if both are provided, then `serviceAccount` will be used
    public let apiKey: APIKey?
    
    /// Path to destination directory where generated strings files should be saved
    public let destinations: [String: String]
    
    /// Name of column that contains keys to be localized
    public let keyColumnName: String
    
    /// Mapping of language column names to app languages
    public let languageMapping: LanguageMapping
    
    /// Path to service account file that will be used to access spreadsheet
    ///
    /// Either `apiKey` or `serviceAccount` must be provided, if both are provided, then `serviceAccount` will be used
    public let serviceAccount: String?
    
    /// Identifier of spreadsheet that should be downloaded
    public let spreadsheetID: String
    
    /// Name of spreadsheet tab to be fetched
    ///
    /// If nothing is specified, we will use the first tab in spreadsheet
    public let spreadsheetTabName: String?
    
    /// Name of default strings file that should be generated
    public let defaultFileName: String
    
    public init(
        apiKey: APIKey?,
        destinations: [String: String],
        keyColumnName: String,
        languageMapping: LanguageMapping,
        serviceAccount: String?,
        spreadsheetID: String,
        spreadsheetTabName: String?,
        defaultFileName: String
    ) {
        self.apiKey = apiKey
        self.destinations = destinations
        self.keyColumnName = keyColumnName
        self.languageMapping = languageMapping
        self.serviceAccount = serviceAccount
        self.spreadsheetID = spreadsheetID
        self.spreadsheetTabName = spreadsheetTabName
        self.defaultFileName = defaultFileName
    }
    
    init(v1Config configuration: ConfigurationV1) {
        apiKey = configuration.apiKey
        keyColumnName = configuration.keyColumnName
        languageMapping = configuration.languageMapping
        serviceAccount = configuration.serviceAccount
        spreadsheetID = configuration.spreadsheetID
        spreadsheetTabName = configuration.spreadsheetTabName
        defaultFileName = configuration.stringsFileName?.removingSuffix(".strings") ?? "Localizable"
        destinations = [
            defaultFileName: configuration.destinationDir
        ]
        
        if configuration.stringsDictFileName != nil {
            warn("Usage of `stringsDictFileName` has no further effect now")
        }
    }
}
