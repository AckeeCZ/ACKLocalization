//
//  ACKLocalization.swift
//  
//
//  Created by Jakub Olejník on 11/12/2019.
//

import Combine
import Foundation

public typealias MappedValues = [String: [LocRow]]

public final class ACKLocalization {
    private let authAPI: AuthAPIServicing
    private let sheetsAPI: SheetsAPIServicing
    private var fetchCancellable: Cancellable?
    
    // MARK: - Initializers
    
    public init(authAPI: AuthAPIServicing = AuthAPIService(), sheetsAPI: SheetsAPIServicing = SheetsAPIService()) {
        self.authAPI = authAPI
        self.sheetsAPI = sheetsAPI
    }
    
    // MARK: - Public interface
    
    public func run() {
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        do {
            let config = try loadConfiguration()
            
            fetchCancellable = fetchSheetValues(config)
                .flatMap { [weak self] in self?.transformValuesPublisher($0, with: config) ?? Fail(error: LocalizationError(message: "Unable to transform values")).eraseToAnyPublisher() }
                .sink(receiveCompletion: { [weak self] result in
                    switch result {
                    case .failure(let error): self?.displayError(error)
                    case .finished:
                        print("succes")
                        break
                    }
                    dispatchGroup.leave()
                }) { _ in
                    
            }
        } catch {
          switch error {
            case let localizationError as LocalizationError:
                displayError(localizationError)
            default:
                print(error)
            }
        }
        
        dispatchGroup.wait()
    }
    
    public func fetchSheetValues(_ spreadsheetTabName: String?, spreadsheetId: String, serviceAccount: ServiceAccount) -> AnyPublisher<ValueRange, LocalizationError> {
        let sheetsAPI = self.sheetsAPI
        var accessToken: AccessToken?
        
        return authAPI.fetchAccessToken(serviceAccount: serviceAccount)
            .handleEvents(receiveOutput: { accessToken = $0 })
            .flatMap { sheetsAPI.fetchSpreadsheet(spreadsheetId, accessToken: $0) }
            .flatMap { sheetsAPI.fetchSheet(spreadsheetTabName, from: $0, accessToken: accessToken!) }
            .mapError(LocalizationError.init)
            .eraseToAnyPublisher()
    }
    
    public func transformValues(_ valueRange: ValueRange, with mapping: LanguageMapping, keyColumnName: String) throws -> MappedValues {
        // check that we have any column, that contains string keys
        guard let keyColIndex = valueRange.firstIndex(columnName: keyColumnName) else {
            throw LocalizationError(message: "Unable to find column named `" + keyColumnName + "` in the first sheet row")
        }
        
        // spreadsheet contains only header row
        guard valueRange.values.count > 1 else { return [:] }
        
        var result = MappedValues()
        
        // skip first row as that is the header row
        valueRange.values[1...].forEach { rowValues in
            // skip rows which do not contain a key
            guard let key = rowValues[safe: keyColIndex], key.count > 0 else { return }
            
            mapping.forEach { sheetColName, langCode in
                // find index of current language
                guard let langIndex = valueRange.firstIndex(columnName: sheetColName) else { return }
                
                // try to fetch 
                if let value = rowValues[safe: langIndex].map ({ LocRow(key: key, value: $0) }) {
                    var langRows = result[langCode] ?? []
                    langRows.append(value)
                    result[langCode] = langRows
                }
            }
        }
        
        return result
    }
    
    public func transformValuesPublisher(_ valueRange: ValueRange, with mapping: LanguageMapping, keyColumnName: String) -> AnyPublisher<MappedValues, LocalizationError> {
        Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(LocalizationError(message: "Unable to transform values")))
                return
            }
            
            do {
                let transformedValues = try self.transformValues(valueRange, with: mapping, keyColumnName: keyColumnName)
                promise(.success(transformedValues))
            } catch {
                switch error {
                case let localizationError as LocalizationError: promise(.failure(localizationError))
                default: promise(.failure(LocalizationError(message: error.localizedDescription)))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    public func transformValuesPublisher(_ valueRange: ValueRange, with config: Configuration) -> AnyPublisher<MappedValues, LocalizationError> {
        transformValuesPublisher(valueRange, with: config.languageMapping, keyColumnName: config.keyColumnName)
    }
    
    // MARK: - Private helpers
    
    private func loadConfiguration() throws -> Configuration {
        guard let configData = FileManager.default.contents(atPath: "localization.json") else {
            throw LocalizationError(message: "Unable to find `localization.json` config file. Does it exist in current directory?")
        }
        
        do {
            return try JSONDecoder().decode(Configuration.self, from: configData)
        } catch {
            throw LocalizationError(message: "Unable to read `localization.json` - " + error.localizedDescription)
        }
    }
    
    private func loadServiceAccount(from config: Configuration) throws -> ServiceAccount {
        guard let serviceAccountData = FileManager.default.contents(atPath: config.serviceAccount) else {
            throw LocalizationError(message: "Unable to load service account at " + config.serviceAccount)
        }
        
        do {
            return try JSONDecoder().decode(ServiceAccount.self, from: serviceAccountData)
        } catch {
            throw LocalizationError(message: "Unable to read `" + config.serviceAccount + "` - " + error.localizedDescription)
        }
    }
    
    private func fetchSheetValues(_ config: Configuration) -> AnyPublisher<ValueRange, LocalizationError> {
        do {
            let serviceAccount = try loadServiceAccount(from: config)
            return fetchSheetValues(config.spreadsheetTabName, spreadsheetId: config.spreadsheetID, serviceAccount: serviceAccount)
        } catch {
            switch error {
            case let localizationError as LocalizationError:
                return Fail(error: localizationError).eraseToAnyPublisher()
            default:
                return Fail(error: LocalizationError(message: error.localizedDescription)).eraseToAnyPublisher()
            }
        }
    }
    
    private func displayError(_ localizationError: LocalizationError) {
        print("[ERROR]", localizationError.message)
    }
}
