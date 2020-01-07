//
//  LocalizationError.swift
//  
//
//  Created by Jakub Olejník on 12/12/2019.
//

import Foundation

/// Error that is thrown throughout the whole tool
public struct LocalizationError: Error {
    /// Descriptive message of error
    public let message: String
    
    /// Code of error
    public let code: Code?
    
    var localizedDescription: String { message }
    
    // MARK: Innitializers
    
    public init(message: String, code: Code? = nil) {
        self.message = message
        self.code = code
    }
}

extension LocalizationError {
    /// Creates `LocalizationError` from `RequestError`
    init(_ error: RequestError) {
        message = error.localizedDescription
        
        if let googleError = error.underlyingError as? GoogleError, googleError.isMissingTab {
            code = .missingSheetTab
        } else {
            code = nil
        }
    }
}

extension LocalizationError {
    /// Code that helps to determine what went wrong
    public enum Code {
        /// Error while fetching spreadsheet values - given tab doesn't exist
        case missingSheetTab
    }
}
