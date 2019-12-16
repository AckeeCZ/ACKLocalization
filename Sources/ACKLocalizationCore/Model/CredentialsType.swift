//
//  File.swift
//  
//
//  Created by Jakub Olejník on 16/12/2019.
//

import Foundation

public protocol CredentialsType {
    func addToRequest(_ request: inout URLRequest)
}
