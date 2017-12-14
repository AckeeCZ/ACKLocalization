//
//  SafeSubscript.swift
//  LocalizationCore
//
//  Created by Jakub Olejník on 14/12/2017.
//

import Foundation

/// Safe subscript for collections
public protocol SafeRandomAccessCollection: RandomAccessCollection {
    subscript(safe index: Int) -> Iterator.Element? { get }
}

extension Array: SafeRandomAccessCollection {
    public subscript(safe index: Int) -> Iterator.Element? {
        return indices ~= index ? self[index] : nil
    }
}
