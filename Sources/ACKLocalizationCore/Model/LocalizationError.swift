//
//  LocalizationError.swift
//  
//
//  Created by Jakub Olejník on 12/12/2019.
//

import Foundation

public struct LocalizationError: Error {
    public let message: String
}

extension LocalizationError {
    init(_ error: RequestError) {
        message = error.localizedDescription
    }
}
