//
//  URLSessionExtensions.swift
//  
//
//  Created by Jakub Olejník on 16/12/2019.
//

import Combine
import Foundation

internal extension URLSession.DataTaskPublisher {
    /// Checks response status code, if it is not inside 200 - 300 then returns an error
    func validate() -> AnyPublisher<Data, RequestError> {
        tryMap { data, response -> Data in
            // if we do not have any response, assume it is valid
            guard let response = response as? HTTPURLResponse else { return data }
            
            if (200..<300).contains(response.statusCode) {
                return data
            }
            
            let googleError = (try? JSONDecoder().decode([String: GoogleError].self, from: data))?["error"]
            let message = [
                "Response status code (" + String(response.statusCode) + ") was unacceptable",
                googleError?.message
                ]
                .compactMap { $0 }
                .joined(separator: " - ")
            
            throw RequestError(underlyingError: googleError, message: message)
        }
        .mapError { $0 as! RequestError } // the tryMap can throw only RequestErrors
        .eraseToAnyPublisher()
    }
}
