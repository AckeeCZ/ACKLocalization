//
//  Configuration.swift
//  
//
//  Created by Jakub Olejník on 11/12/2019.
//

import Foundation

/// Object representing app parameters
struct Configuration: Decodable {
    /// Path to destination directory where generated strings files should be saved
    let destinationDir: String
    
    /// Name of column that contains keys to be localized
    let keyColumnName: String
    
    /// Mapping of language column names to app languages
    let languageMapping: [String: String]
    
    /// Path to service account file that will be used to access spreadsheet
    let serviceAccount: String
    
    /// Identifier of spreadsheet that should be downloaded
    let spreadsheetID: String
    
    /// Name of strings file that should be generated
    let stringsFileName: String?
}
