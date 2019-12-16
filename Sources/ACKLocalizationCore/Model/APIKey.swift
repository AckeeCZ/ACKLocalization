//
//  APIKey.swift
//  
//
//  Created by Jakub Olejník on 16/12/2019.
//

import Foundation

public struct APIKey {
    public let value: String
}

extension APIKey: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.value = value
    }
}

extension APIKey: CredentialsType {
    public func addToRequest(_ request: inout URLRequest) {
        guard let url = request.url else { return }
        var urlComponents = URLComponents(string: url.absoluteString)
        var queryItems = urlComponents?.queryItems ?? .init()
        queryItems.append(.init(name: "key", value: value))
        urlComponents?.queryItems = queryItems
        request.url = urlComponents?.url
    }
}

extension APIKey: Decodable {
    public init(from decoder: Decoder) throws {
        value = try decoder.singleValueContainer().decode(String.self)
    }
}
