//
//  RequestError.swift
//  
//
//  Created by Jakub Olejník on 11/12/2019.
//

import Foundation

/// Struct used to represent errors during network requests
public struct RequestError: Error {
    /// Error received e.g. from `URLSession`
    public let underlyingError: Error?
    
    /// Message to be displayed
    public let message: String
    
    public var localizedDescription: String { message }
}

public extension RequestError {
    init(underlyingError: Error) {
        // if we already received `RequestError` make sure that it is not wrapped with another `RequestError`,
        // it is not nice but is simple and it works
        if let requestError = underlyingError as? RequestError {
            self = requestError
        } else {
            self.underlyingError = underlyingError
            self.message = underlyingError.localizedDescription
        }
    }
    
    init(message: String) {
        self.underlyingError = nil
        self.message = message
    }
}
