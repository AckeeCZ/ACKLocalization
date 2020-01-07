//
//  File.swift
//  
//
//  Created by Jakub Olejník on 16/12/2019.
//

import Foundation

/// Represents error returned by Google API
struct GoogleError: Error, Decodable {
    let message: String
    let status: String
    let code: Int
    
    var localizedDescription: String { message}
}

extension GoogleError {
    /// Determine if `self` is error because of missing requested tab in spreadsheet
    var isMissingTab: Bool {
        code == 400 && status == "INVALID_ARGUMENT"
    }
}
