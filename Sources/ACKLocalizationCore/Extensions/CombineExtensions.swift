import Combine
import Foundation

// MARK: - SheetsAPIServicing Combine extensions

public extension SheetsAPIServicing {
    /// Fetch information about given spreadsheet
    func fetchSpreadsheet(_ identifier: String) -> AnyPublisher<Spreadsheet, RequestError> {
        Future { [weak self] promise in
            Task {
                do {
                    guard let result = try await self?.fetchSpreadsheet(identifier) else {
                        promise(.failure(RequestError(message: "Unable to fetch spreadsheet")))
                        return
                    }
                    promise(.success(result))
                } catch let error as RequestError {
                    promise(.failure(error))
                } catch {
                    promise(.failure(RequestError(underlyingError: error)))
                }
            }
        }.eraseToAnyPublisher()
    }

    /// Fetch content of given sheet from given spreadsheet
    func fetchSheet(_ sheetName: String?, from spreadsheet: Spreadsheet) -> AnyPublisher<ValueRange, RequestError> {
        Future { [weak self] promise in
            Task {
                do {
                    guard let result = try await self?.fetchSheet(sheetName, from: spreadsheet) else {
                        promise(.failure(RequestError(message: "Unable to fetch sheet")))
                        return
                    }
                    promise(.success(result))
                } catch let error as RequestError {
                    promise(.failure(error))
                } catch {
                    promise(.failure(RequestError(underlyingError: error)))
                }
            }
        }.eraseToAnyPublisher()
    }
}

// MARK: - ACKLocalization Combine extensions

public extension ACKLocalization {
    /// Fetches content of given sheet from spreadsheet using given `serviceAccount`
    ///
    /// If not `spreadsheetTabName` is provided, the first in the spreadsheet is used
    func fetchSheetValues(
        _ spreadsheetTabName: String?,
        spreadsheetId: String,
        serviceAccountPath: String?
    ) -> AnyPublisher<ValueRange, LocalizationError> {
        Future { [weak self] promise in
            Task {
                do {
                    guard let result = try await self?.fetchSheetValues(
                        spreadsheetTabName,
                        spreadsheetId: spreadsheetId,
                        serviceAccountPath: serviceAccountPath
                    ) else {
                        promise(.failure(LocalizationError(message: "Unable to fetch sheet values")))
                        return
                    }
                    promise(.success(result))
                } catch let error as LocalizationError {
                    promise(.failure(error))
                } catch {
                    promise(.failure(LocalizationError(message: error.localizedDescription)))
                }
            }
        }.eraseToAnyPublisher()
    }

    func fetchSheetValues(
        _ spreadsheetTabName: String?,
        spreadsheetId: String,
        apiKey: APIKey
    ) -> AnyPublisher<ValueRange, LocalizationError> {
        Future { [weak self] promise in
            Task {
                do {
                    guard let result = try await self?.fetchSheetValues(
                        spreadsheetTabName,
                        spreadsheetId: spreadsheetId,
                        apiKey: apiKey
                    ) else {
                        promise(.failure(LocalizationError(message: "Unable to fetch sheet values")))
                        return
                    }
                    promise(.success(result))
                } catch let error as LocalizationError {
                    promise(.failure(error))
                } catch {
                    promise(.failure(LocalizationError(message: error.localizedDescription)))
                }
            }
        }.eraseToAnyPublisher()
    }

    /// Fetches sheet values from given `config`
    func fetchSheetValues(_ config: Configuration) -> AnyPublisher<ValueRange, LocalizationError> {
        Future { [weak self] promise in
            Task {
                do {
                    guard let result = try await self?.fetchSheetValues(config) else {
                        promise(.failure(LocalizationError(message: "Unable to fetch sheet values")))
                        return
                    }
                    promise(.success(result))
                } catch let error as LocalizationError {
                    promise(.failure(error))
                } catch {
                    promise(.failure(LocalizationError(message: error.localizedDescription)))
                }
            }
        }.eraseToAnyPublisher()
    }

    /// Transforms given value range using given language mapping
    func transformValuesPublisher(
        _ valueRange: ValueRange,
        with mapping: LanguageMapping,
        keyColumnName: String
    ) -> AnyPublisher<MappedValues, LocalizationError> {
        Future { [weak self] promise in
            guard let self else {
                promise(.failure(LocalizationError(message: "Unable to transform values")))
                return
            }
            do {
                let result = try self.transformValues(valueRange, with: mapping, keyColumnName: keyColumnName)
                promise(.success(result))
            } catch let error as LocalizationError {
                promise(.failure(error))
            } catch {
                promise(.failure(LocalizationError(message: error.localizedDescription)))
            }
        }.eraseToAnyPublisher()
    }

    /// Transforms given value range using given config
    func transformValuesPublisher(
        _ valueRange: ValueRange,
        with config: Configuration
    ) -> AnyPublisher<MappedValues, LocalizationError> {
        transformValuesPublisher(valueRange, with: config.languageMapping, keyColumnName: config.keyColumnName)
    }

    /// Saves given `mappedValues` to correct directory file
    func saveMappedValuesPublisher(
        _ mappedValues: MappedValues,
        defaultFileName: String,
        destinations: [String: String]
    ) -> AnyPublisher<Void, LocalizationError> {
        Future { [weak self] promise in
            guard let self else {
                promise(.failure(LocalizationError(message: "Unable to save mapped values")))
                return
            }
            do {
                try self.saveMappedValues(mappedValues, defaultFileName: defaultFileName, destinations: destinations)
                promise(.success(()))
            } catch let error as LocalizationError {
                promise(.failure(error))
            } catch {
                promise(.failure(LocalizationError(message: error.localizedDescription)))
            }
        }.eraseToAnyPublisher()
    }

    /// Saves given `mappedValues` to correct directory file
    func saveMappedValuesPublisher(
        _ mappedValues: MappedValues,
        config: Configuration
    ) -> AnyPublisher<Void, LocalizationError> {
        saveMappedValuesPublisher(
            mappedValues,
            defaultFileName: config.defaultFileName,
            destinations: config.destinations
        )
    }
}
