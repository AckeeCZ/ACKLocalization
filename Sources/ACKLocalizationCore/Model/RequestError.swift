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
    public let underlyingError: Error
}
