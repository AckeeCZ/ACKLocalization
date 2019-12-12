//
//  SheetsAPIService.swift
//  
//
//  Created by Jakub Olejník on 11/12/2019.
//

import Combine
import Foundation

public protocol SheetsAPIServicing {
    func fetchSpreadsheet(_ identifier: String, accessToken: AccessToken) -> AnyPublisher<Spreadsheet, RequestError>
    func fetchSheet(_ sheetName: String?, from spreadsheet: Spreadsheet, accessToken: AccessToken) -> AnyPublisher<ValueRange, RequestError>
}

public struct SheetsAPIService: SheetsAPIServicing {
    private let session: URLSession
    
    // MARK: - Initializers
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    // MARK: - API calls
    
    public func fetchSpreadsheet(_ identifier: String, accessToken: AccessToken) -> AnyPublisher<Spreadsheet, RequestError> {
        let url = URL(string: "https://sheets.googleapis.com/v4/spreadsheets/" + identifier)!
        var request = URLRequest(url: url)
        request.addValue(accessToken.headerValue, forHTTPHeaderField: "Authorization")
        
        return session.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: Spreadsheet.self, decoder: JSONDecoder())
            .mapError(RequestError.init)
            .eraseToAnyPublisher()
    }
    
    public func fetchSheet(_ sheetName: String?, from spreadsheet: Spreadsheet, accessToken: AccessToken) -> AnyPublisher<ValueRange, RequestError> {
        let sheetName = sheetName ?? spreadsheet.sheets.first?.properties.title ?? ""
        var urlComponents = URLComponents(string: "https://sheets.googleapis.com/v4/spreadsheets/" + spreadsheet.spreadsheetId + "/values/" + sheetName.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!)!
        urlComponents.queryItems = [URLQueryItem(name: "valueRenderOption", value: "UNFORMATTED_VALUE")]
        var request = URLRequest(url: urlComponents.url!)
        request.addValue(accessToken.headerValue, forHTTPHeaderField: "Authorization")
        
        return session.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: ValueRange.self, decoder: JSONDecoder())
            .mapError(RequestError.init)
            .eraseToAnyPublisher()
    }
}