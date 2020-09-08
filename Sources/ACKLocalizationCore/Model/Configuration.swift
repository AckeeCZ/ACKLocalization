//
//  Configuration.swift
//  
//
//  Created by Jakub Olejník on 11/12/2019.
//

import Foundation

public typealias LanguageMapping = [String: String]

/// Object representing app parameters
public struct Configuration: Decodable {
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
    
    /// Path to widget target directory where generated strings files should be saved
    public let widgetDestinationDir: String?
    
    public init(apiKey: APIKey?, destinationDir: String, keyColumnName: String, languageMapping: LanguageMapping, serviceAccount: String?,
                spreadsheetID: String, spreadsheetTabName: String?, stringsFileName: String?, stringsDictFileName: String?, widgetdestinationDir: String?) {
        self.apiKey = apiKey
        self.destinationDir = destinationDir
        self.keyColumnName = keyColumnName
        self.languageMapping = languageMapping
        self.serviceAccount = serviceAccount
        self.spreadsheetID = spreadsheetID
        self.spreadsheetTabName = spreadsheetTabName
        self.stringsFileName = stringsFileName
        self.stringsDictFileName = stringsDictFileName
        self.widgetDestinationDir = widgetdestinationDir
    }
}
