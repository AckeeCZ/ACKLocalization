//
//  SheetsAPIService.swift
//  
//
//  Created by Jakub Olejník on 11/12/2019.
//

import Combine
import Foundation

/// Protocol wrapping service that fetches information about spreadsheet
public protocol SheetsAPIServicing: AnyObject {
    /// Access token that will be used with all requests
    var credentials: CredentialsType? { get set }
    
    /// Fetch information about given spreadsheet
    ///
    /// Uses `accessToken` property for authorization
    func fetchSpreadsheet(_ identifier: String) -> AnyPublisher<Spreadsheet, RequestError>
    
    /// Fetch content of given sheet from given spreadsheet
    ///
    /// If no `sheetName` is provided we use the first sheet
    /// Uses `accessToken` property for authorization
    func fetchSheet(_ sheetName: String?, from spreadsheet: Spreadsheet) -> AnyPublisher<ValueRange, RequestError>
}

/// Service that fetches information about spreadsheet
public final class SheetsAPIService: SheetsAPIServicing {
    /// Access token that will be used with all requests
    public var credentials: CredentialsType?
    
    private let session: URLSession
    
    // MARK: - Initializers
    
    public init(session: URLSession = .shared, credentials: CredentialsType? = nil) {
        self.session = session
        self.credentials = credentials
    }
    
    // MARK: - API calls
    
    /// Fetch information about given spreadsheet
    ///
    /// Uses `accessToken` property for authorization
    public func fetchSpreadsheet(_ identifier: String) -> AnyPublisher<Spreadsheet, RequestError> {
        let url = URL(string: "https://sheets.googleapis.com/v4/spreadsheets/" + identifier)!
        var request = URLRequest(url: url)
        credentials?.addToRequest(&request)
        
        return session.dataTaskPublisher(for: request)
            .validate()
            .decode(type: Spreadsheet.self, decoder: JSONDecoder())
            .mapError(RequestError.init)
            .eraseToAnyPublisher()
    }
    
    /// Fetch content of given sheet from given spreadsheet
    ///
    /// If no `sheetName` is provided we use the first sheet
    /// Uses `accessToken` property for authorization
    public func fetchSheet(_ sheetName: String?, from spreadsheet: Spreadsheet) -> AnyPublisher<ValueRange, RequestError> {
        let sheetName = sheetName ?? spreadsheet.sheets.first?.properties.title ?? ""
        var urlComponents = URLComponents(string: "https://sheets.googleapis.com/v4/spreadsheets/" + spreadsheet.spreadsheetId + "/values/" + sheetName.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!)!
        urlComponents.queryItems = [URLQueryItem(name: "valueRenderOption", value: "UNFORMATTED_VALUE")]
        var request = URLRequest(url: urlComponents.url!)
        credentials?.addToRequest(&request)
        
        return session.dataTaskPublisher(for: request)
            .validate()
            .decode(type: ValueRange.self, decoder: JSONDecoder())
            .mapError(RequestError.init)
            .eraseToAnyPublisher()
    }
}
