//
//  RequestError.swift
//  
//
//  Created by Jakub Olejník on 11/12/2019.
//

import Foundation

struct RequestError: Error {
    let underlyingError: Error
}
