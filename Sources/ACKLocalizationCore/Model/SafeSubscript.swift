//
//  SafeSubscript.swift
//  
//
//  Created by Jakub Olejník on 12/12/2019.
//

import Foundation

internal extension RandomAccessCollection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
