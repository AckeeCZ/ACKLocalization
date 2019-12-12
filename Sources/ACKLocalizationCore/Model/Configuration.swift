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
    /// Path to destination directory where generated strings files should be saved
    public let destinationDir: String
    
    /// Name of column that contains keys to be localized
    public let keyColumnName: String
    
    /// Mapping of language column names to app languages
    public let languageMapping: LanguageMapping
    
    /// Path to service account file that will be used to access spreadsheet
    public let serviceAccount: String
    
    /// Identifier of spreadsheet that should be downloaded
    public let spreadsheetID: String
    
    /// Name of spreadsheet tab to be fetched
    ///
    /// If nothing is specified, we will use the first tab in spreadsheet
    public let spreadsheetTabName: String?
    
    /// Name of strings file that should be generated
    public let stringsFileName: String?
}