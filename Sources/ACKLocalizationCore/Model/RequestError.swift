//
//  RequestError.swift
//  
//
//  Created by Jakub Olejník on 11/12/2019.
//

import Foundation

public struct RequestError: Error {
    public let underlyingError: Error
}
