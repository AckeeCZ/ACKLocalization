//
//  ACKLocalization.swift
//  
//
//  Created by Jakub Olejník on 11/12/2019.
//

import Combine
import Foundation

/// Type used for representation of result map values that will be written to destination file
public typealias MappedValues = [String: [LocRow]]

/// Class containing all `ACKLocalization` logic
public final class ACKLocalization {
    /// Auth API used to fetch access token for spreadsheet API
    private let authAPI: AuthAPIServicing
    
    /// Spreadsheet API used to fetch spreadsheet content
    private let sheetsAPI: SheetsAPIServicing
    
    private var fetchCancellable: Cancellable?
    
    // MARK: - Initializers
    
    public init(authAPI: AuthAPIServicing = AuthAPIService(), sheetsAPI: SheetsAPIServicing = SheetsAPIService()) {
        self.authAPI = authAPI
        self.sheetsAPI = sheetsAPI
    }
    
    // MARK: - Public interface
    
    /// Main that loads configuration from _localization.json_, fetches access token and loads content of spreadsheet
    public func run() {
        callThrowingCode {
            let config = try loadConfiguration()
            try run(configuration: config)
        }
    }
    
    public func run(configuration config: Configuration) throws {
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        fetchCancellable = fetchSheetValues(config)
            .flatMap { [weak self] in self?.transformValuesPublisher($0, with: config) ?? Fail(error: LocalizationError(message: "Unable to transform values")).eraseToAnyPublisher() }
            .flatMap { [weak self] in self?.saveMappedValuesPublisher($0, config: config) ?? Fail(error: LocalizationError(message: "Unable to save mapped values")).eraseToAnyPublisher() }
            .sink(receiveCompletion: { [weak self] result in
                switch result {
                case .failure(let error):
                    self?.displayError(error)
                    exit(1)
                case .finished: self?.displaySuccess()
                }
                dispatchGroup.leave()
            }) { _ in }
        dispatchGroup.wait()
    }
    
    /// Fetches content of given sheet from spreadsheet using given `serviceAccount`
    ///
    /// If not `spreadsheetTabName` is provided, the first in the spreadsheet is used
    public func fetchSheetValues(_ spreadsheetTabName: String?, spreadsheetId: String, serviceAccount: ServiceAccount) -> AnyPublisher<ValueRange, LocalizationError> {
        let sheetsAPI = self.sheetsAPI
        
        return authAPI.fetchAccessToken(serviceAccount: serviceAccount)
            .handleEvents(receiveOutput: { sheetsAPI.credentials = $0 })
            .map { _ in }
            .flatMap { sheetsAPI.fetchSpreadsheet(spreadsheetId) }
            .flatMap { sheetsAPI.fetchSheet(spreadsheetTabName, from: $0) }
            .mapError(LocalizationError.init)
            .eraseToAnyPublisher()
    }
    
    public func fetchSheetValues(_ spreadsheetTabName: String?, spreadsheetId: String, apiKey: APIKey) -> AnyPublisher<ValueRange, LocalizationError> {
        let sheetsAPI = self.sheetsAPI
        sheetsAPI.credentials = apiKey
        
        return sheetsAPI.fetchSpreadsheet(spreadsheetId)
            .flatMap { sheetsAPI.fetchSheet(spreadsheetTabName, from: $0) }
            .mapError(LocalizationError.init)
            .eraseToAnyPublisher()
    }
    
    /// Transforms given value range (content of spreadsheet) using given language mapping to `MappedValue` which can be written out to output file
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
                
                let value = LocRow(key: key, value: rowValues[safe: langIndex] ?? "")
                
                var langRows = result[langCode] ?? []
                langRows.append(value)
                result[langCode] = langRows
            }
        }
        
        return result
    }
    
    /// Transforms given value range (content of spreadsheet) using given language mapping to `MappedValue` which can be written out to output file
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
    
    /// Transforms given value range (content of spreadsheet) using given config to `MappedValue` which can be written out to output file
    public func transformValuesPublisher(_ valueRange: ValueRange, with config: Configuration) -> AnyPublisher<MappedValues, LocalizationError> {
        transformValuesPublisher(valueRange, with: config.languageMapping, keyColumnName: config.keyColumnName)
    }
    
    /// Builds plurals from `rows` of each language
    ///
    /// - Parameter `rows`: All translations of the selected language
    /// - Returns: Plural keys that are specified in `rows`
    func buildPlurals(from rows: [LocRow]) throws -> [String: PluralRuleWrapper] {
        var plurals: [String: PluralRuleWrapper] = [:]
        
        let regular = try NSRegularExpression(pattern: Constants.pluralPattern, options: [])
        
        try rows.forEach {
            // Try to split the translation key into the actual key and the plural rule key
            // based on the predefined regular expression
            let matches = regular.matches(in: $0.key, options: [], range: NSRange(location: 0, length: $0.key.utf16.count))
            
            // Skip key which doesn't contain the translation rule
            // There should be always exactly one match
            guard let match = matches.first else { return }
            
            // Index 0 – range of the whole string
            // Index 1 – range of the translation key
            let translationKeyRange = match.range(at: 1)
            
            // Check if the actual translation key is presented
            guard translationKeyRange.location != NSNotFound else { throw PluralError.missingTranslationKey($0.key) }

            // Get the actual translation key from the `translationKeyRange`
            let translationKey = ($0.key as NSString).substring(with: translationKeyRange)

            // Index 2 – range of the plural rule
            let pluralRuleRange = match.range(at: 2)
            
            // Check if the plural rule is presented
            guard pluralRuleRange.location != NSNotFound else { throw PluralError.missingPluralRule($0.key) }
            
            // Get the plural rule from the `pluralRuleRange`
            let pluralRuleString = ($0.key as NSString).substring(with: pluralRuleRange)

            // Check if the plural rule is valid
            guard let pluralRuleKey = PluralRuleKey(rawValue: pluralRuleString) else { throw PluralError.invalidPluralRule($0.key) }
            
            // Load all translations for the given key
            var currentTranslations = plurals[translationKey]?.translations ?? []
            
            // Create new rule and add it to the other rules
            let translation = PluralRule(key: pluralRuleKey, value: $0.value)
            currentTranslations.append(translation)
            plurals[translationKey] = PluralRuleWrapper(translations: currentTranslations)
        }
        
        return plurals
    }
    
    /// Saves given `mappedValues` to correct directory file
    public func saveMappedValues(_ mappedValues: MappedValues, directory: String, stringsFileName: String, stringsDictFileName: String) throws {
        try mappedValues.forEach { langCode, rows in
            let dirPath = directory + "/" + langCode + ".lproj"
            let filePath = dirPath + "/" + stringsFileName
            let pluralsPath = dirPath + "/" + stringsDictFileName
            
            try? FileManager.default.removeItem(atPath: filePath)
            try? FileManager.default.createDirectory(atPath: dirPath, withIntermediateDirectories: true)

            do {
                // Collection of plural rules for a given translation key.
                // Translation key is the base without the suffix ##{plural-rule}
                let plurals = try buildPlurals(from: rows)
                
                let finalRows = rows
                    // we filter out entries with `plist.` prefix as they will be written into different file
                    .filter { !$0.key.hasPrefix(Constants.plistKeyPrefix + ".") }
                    // Filter out plurals
                    .filter { $0.key.range(of: Constants.pluralPattern, options: .regularExpression) == nil }
                
                try writeRows(finalRows, to: filePath)
                
                // write plist values to appropriate files
                var plistOutputs = [String: [LocRow]]()
                
                rows.filter { $0.key.hasPrefix(Constants.plistKeyPrefix + ".") }.forEach { row in
                    // key format for this type of entry is `plist.<plist_file_name>.<key>`
                    let components = row.key.components(separatedBy: ".")
                    
                    guard components.count > 2 else { return }
                    
                    let plistName = components[1]
                    var rows = plistOutputs[plistName] ?? []
                    rows.append(LocRow(key: components[2...].joined(separator: "."), value: row.value))
                    plistOutputs[plistName] = rows
                }
                
                try plistOutputs.forEach { try writeRows($1, to: dirPath + "/" + $0 + ".strings") }
                
                if plurals.count > 0 {
                    // Create stringDict from data and save it
                    let encoder = PropertyListEncoder()
                    encoder.outputFormat = .xml
                    let data = try encoder.encode(plurals)
                    try data.write(to: URL(fileURLWithPath: pluralsPath))
                }
            } catch {
                throw LocalizationError(message: "Unable to save mapped values - " + error.localizedDescription)
            }
        }
    }
    
    /// Saves given `mappedValues` to correct directory file
    public func saveMappedValuesPublisher(_ mappedValues: MappedValues, directory: String, stringsFileName: String, stringsDictFileName: String) -> AnyPublisher<Void, LocalizationError> {
        Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(LocalizationError(message: "Unable to save mapped values")))
                return
            }
            
            do {
                try self.saveMappedValues(mappedValues, directory: directory, stringsFileName: stringsFileName, stringsDictFileName: stringsDictFileName)
                promise(.success(()))
            } catch {
                switch error {
                case let localizationError as LocalizationError: promise(.failure(localizationError))
                default: promise(.failure(LocalizationError(message: error.localizedDescription)))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    /// Saves given `mappedValues` to correct directory file
    public func saveMappedValuesPublisher(_ mappedValues: MappedValues, config: Configuration) -> AnyPublisher<Void, LocalizationError> {
        saveMappedValuesPublisher(mappedValues, directory: config.destinationDir, stringsFileName: config.stringsFileName ?? "Localizable.strings", stringsDictFileName: config.stringsDictFileName ?? "Localizable.stringsdict")
    }
    
    /// Fetches sheet values from given `config`
    public func fetchSheetValues(_ config: Configuration) -> AnyPublisher<ValueRange, LocalizationError> {
        do {
            if let serviceAccountPath = config.serviceAccount {
                let serviceAccount = try loadServiceAccount(from: serviceAccountPath)
                return fetchSheetValues(config.spreadsheetTabName, spreadsheetId: config.spreadsheetID, serviceAccount: serviceAccount)
            } else if let apiKey = config.apiKey {
                return fetchSheetValues(config.spreadsheetTabName, spreadsheetId: config.spreadsheetID, apiKey: apiKey)
            } else {
                throw LocalizationError(message: "Either `apiKey` or `serviceAccount` must be provided in `localization.json` file")
            }
        } catch {
            switch error {
            case let localizationError as LocalizationError:
                return Fail(error: localizationError).eraseToAnyPublisher()
            default:
                return Fail(error: LocalizationError(message: error.localizedDescription)).eraseToAnyPublisher()
            }
        }
    }
    
    // MARK: - Private helpers
    
    /// Loads configuration from `localization.json` file
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
    
    /// Loads service account from given `config`
    private func loadServiceAccount(from path: String) throws -> ServiceAccount {
        guard let serviceAccountData = FileManager.default.contents(atPath: path) else {
            throw LocalizationError(message: "Unable to load service account at " + path)
        }
        
        do {
            return try JSONDecoder().decode(ServiceAccount.self, from: serviceAccountData)
        } catch {
            throw LocalizationError(message: "Unable to read service account from `" + path + "` - " + error.localizedDescription)
        }
    }
    
    /// Actually writes given `rows` to given `file`
    private func writeRows(_ rows: [LocRow], to file: String) throws {
        guard rows.count > 0 else { return }
        
        try rows.map { $0.localizableRow }
            .joined(separator: "\n")
            .write(toFile: file, atomically: true, encoding: .utf8)
    }
    
    /// Displays error to stdout
    private func displayError(_ localizationError: LocalizationError) {
        let message = "❌ " + localizationError.message
        FileHandle.standardError.write(message.data(using: .utf8)!)
    }
    
    /// Displays success to stdout
    private func displaySuccess() {
        print("✅ Successfully generated localizations!")
    }
    
    /// Calls throwing code and deals with its errors
    private func callThrowingCode(code: (() throws -> Void)) {
        do {
            try code()
        } catch {
          switch error {
            case let localizationError as LocalizationError:
                displayError(localizationError)
            default:
                print(error)
            }
            exit(1)
        }
    }
}
