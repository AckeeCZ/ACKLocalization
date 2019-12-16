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
    
    var localizedDescription: String { message }
}

extension LocalizationError {
    /// Creates `LocalizationError` from `RequestError`
    init(_ error: RequestError) {
        message = error.localizedDescription
    }
}
