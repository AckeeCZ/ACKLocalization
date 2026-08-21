import Foundation
import GoogleAuth

/// Type used for representation of result map values that will be written to destination file
public typealias MappedValues = [String: [LocRow]]

/// Class containing all `ACKLocalization` logic
public final class ACKLocalization {
    /// Spreadsheet API used to fetch spreadsheet content
    private let sheetsAPI: SheetsAPIService

    /// Filesystem abstraction for writing output files
    private let fileSystem: FileSystem

    // MARK: - Initializers

    public init(sheetsAPI: SheetsAPIService = SheetsAPIServiceImpl()) {
        self.sheetsAPI = sheetsAPI
        self.fileSystem = FileSystemImpl()
    }

    init(sheetsAPI: SheetsAPIService, fileSystem: FileSystem) {
        self.sheetsAPI = sheetsAPI
        self.fileSystem = fileSystem
    }

    // MARK: - Public interface

    /// Main that loads configuration from _localization.json_, fetches access token and loads content of spreadsheet
    public func run() async {
        do {
            let config = try loadConfiguration()
            try await run(configuration: config)
        } catch let error as LocalizationError {
            displayError(error)
            exit(1)
        } catch {
            print(error)
            exit(1)
        }
    }

    public func run(configuration config: Configuration) async throws {
        let values = try await fetchSheetValues(config)
        let mapped = try transformValues(
            values,
            with: config.languageMapping,
            keyColumnName: config.keyColumnName
        )
        try saveMappedValues(
            mapped,
            defaultFileName: config.defaultFileName,
            destinations: config.destinations
        )
        displaySuccess()
    }

    /// Fetches content of given sheet from spreadsheet using given `serviceAccount`
    ///
    /// If not `spreadsheetTabName` is provided, the first in the spreadsheet is used
    public func fetchSheetValues(
        _ spreadsheetTabName: String?,
        spreadsheetId: String,
        serviceAccountPath: String?
    ) async throws -> ValueRange {
        let token = try await fetchGoogleAccessToken(serviceAccountPath: serviceAccountPath)
        sheetsAPI.credentials = token
        let spreadsheet = try await sheetsAPI.fetchSpreadsheet(spreadsheetId)
        return try await sheetsAPI.fetchSheet(spreadsheetTabName, from: spreadsheet)
    }

    public func fetchSheetValues(
        _ spreadsheetTabName: String?,
        spreadsheetId: String,
        apiKey: APIKey
    ) async throws -> ValueRange {
        sheetsAPI.credentials = apiKey
        let spreadsheet = try await sheetsAPI.fetchSpreadsheet(spreadsheetId)
        return try await sheetsAPI.fetchSheet(spreadsheetTabName, from: spreadsheet)
    }

    /// Fetches sheet values from given `config`
    public func fetchSheetValues(_ config: Configuration) async throws -> ValueRange {
        if let serviceAccountPath = config.serviceAccount {
            return try await fetchSheetValues(
                config.spreadsheetTabName,
                spreadsheetId: config.spreadsheetID,
                serviceAccountPath: serviceAccountPath
            )
        } else if let apiKey = config.apiKey {
            return try await fetchSheetValues(
                config.spreadsheetTabName,
                spreadsheetId: config.spreadsheetID,
                apiKey: apiKey
            )
        } else if let serviceAccountPath = ProcessInfo.processInfo.environment[Constants.serviceAccountPath] {
            return try await fetchSheetValues(
                config.spreadsheetTabName,
                spreadsheetId: config.spreadsheetID,
                serviceAccountPath: serviceAccountPath
            )
        } else if let apiKey = ProcessInfo.processInfo.environment[Constants.apiKey] {
            let apiKey = APIKey(value: apiKey)
            return try await fetchSheetValues(
                config.spreadsheetTabName,
                spreadsheetId: config.spreadsheetID,
                apiKey: apiKey
            )
        } else {
            return try await fetchSheetValues(
                config.spreadsheetTabName,
                spreadsheetId: config.spreadsheetID,
                serviceAccountPath: nil
            )
        }
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

    /// Builds plurals from `rows` of each language
    ///
    /// - Parameter `rows`: All translations of the selected language
    /// - Returns: Plural keys that are specified in `rows`
    func buildPlurals(from rows: [LocRow]) throws -> [String: PluralRuleWrapper] {
        var plurals: [String: PluralRuleWrapper] = [:]

        let regular = try NSRegularExpression(pattern: Constants.pluralPattern, options: [])

        try rows.forEach {
            let matches = regular.matches(in: $0.key, options: [], range: NSRange(location: 0, length: $0.key.utf16.count))

            guard let match = matches.first else { return }

            let translationKeyRange = match.range(at: 1)

            guard translationKeyRange.location != NSNotFound else { throw PluralError.missingTranslationKey($0.key) }

            let translationKey = ($0.key as NSString).substring(with: translationKeyRange)

            let pluralRuleRange = match.range(at: 2)

            guard pluralRuleRange.location != NSNotFound else { throw PluralError.missingPluralRule($0.key) }

            let pluralRuleString = ($0.key as NSString).substring(with: pluralRuleRange)

            guard let pluralRuleKey = PluralRuleKey(rawValue: pluralRuleString) else { throw PluralError.invalidPluralRule($0.key) }

            var currentTranslations = plurals[translationKey]?.translations ?? []

            let translation = PluralRule(key: pluralRuleKey, value: $0.value)
            currentTranslations.append(translation)
            plurals[translationKey] = PluralRuleWrapper(translations: currentTranslations)
        }

        return plurals
    }

    /// Saves given `mappedValues` to correct directory file
    public func saveMappedValues(
        _ mappedValues: MappedValues,
        defaultFileName: String,
        destinations: [String: String]
    ) throws {
        struct RowsPerFile {
            let language: String
            let fileName: String
            let rows: [LocRow]
        }

        let defaultFileName = defaultFileName.removingSuffix(".strings")
            .removingSuffix(".stringsdict")
        let rowsPerFile = mappedValues.flatMap { langCode, rows in
             let fileGroups = [String: [LocRow]](grouping: rows) { row in
                let keyComponents = row.key.components(separatedBy: ".")

                guard
                    row.key.hasPrefix(Constants.plistKeyPrefix + "."),
                    keyComponents.count > 2
                else {
                    return defaultFileName
                }

                return keyComponents[1]
            }

            return fileGroups.map { fileName, rows in
                RowsPerFile(
                    language: langCode,
                    fileName: fileName,
                    rows: rows.map { row in
                        let keyComponents = row.key.components(separatedBy: ".")

                        if row.key.hasPrefix(Constants.plistKeyPrefix + "."),
                           keyComponents.count > 2 {
                            return LocRow(
                                key: keyComponents[2...].joined(separator: "."),
                                value: row.value
                            )
                        }

                        return row
                    }
                )
            }
        }

        let defaultDestination = destinations[defaultFileName]

        if defaultDestination == nil {
            warn("No destination for default strings file '\(defaultFileName)'")
            warn("This means that all keys in localization sheet need to have file specified (using `plist.<filename>.` prefix) and all such files need to have its path defined in `destinations` dictionary")
        }

        try rowsPerFile.forEach { fileRows in
            guard let path = destinations[fileRows.fileName] ?? defaultDestination else {
                warn("No destination path found for '\(fileRows.fileName)' strings file")
                return
            }

            let dirPath = ((path as NSString).expandingTildeInPath as NSString)
                .appendingPathComponent(fileRows.language + ".lproj")

            try? fileSystem.createDirectory(atPath: dirPath, withIntermediateDirectories: true)

            let plurals = try buildPlurals(from: fileRows.rows)
            let nonPlurals = fileRows.rows.filter { !$0.isPlural }

            if !nonPlurals.isEmpty {
                let stringsPath = (dirPath as NSString)
                    .appendingPathComponent(fileRows.fileName + ".strings")
                try writeRows(nonPlurals, to: stringsPath)
            }

            if !plurals.isEmpty {
                let stringsDictPath = (dirPath as NSString)
                    .appendingPathComponent(fileRows.fileName + ".stringsdict")
                let encoder = PropertyListEncoder()
                encoder.outputFormat = .xml
                let data = try encoder.encode(plurals)
                try fileSystem.writeData(data, to: URL(fileURLWithPath: stringsDictPath))
            }
        }
    }

    // MARK: - Private helpers

    /// Fetches Google access token using async/await
    private func fetchGoogleAccessToken(serviceAccountPath: String?) async throws -> Token {
        let scopes = ["https://www.googleapis.com/auth/spreadsheets.readonly"]
        let tokenProvider: TokenProvider

        if let serviceAccountPath {
            tokenProvider = try await ServiceAccountTokenProvider(
                serviceAccountPath: serviceAccountPath,
                scopes: scopes
            )
        } else if let tp = await DefaultCredentialsTokenProvider(scopes: scopes) {
            tokenProvider = tp
        } else {
            throw RequestError(message: "Unable to instantiate token provider")
        }

        return try await tokenProvider.token()
    }

    /// Loads configuration from `localization.json` file
    private func loadConfiguration() throws -> Configuration {
        guard let configData = FileManager.default.contents(atPath: "localization.json") else {
            throw LocalizationError(message: "Unable to find `localization.json` config file. Does it exist in current directory?")
        }

        let decoder = JSONDecoder()

        do {
            return try decoder.decode(Configuration.self, from: configData)
        } catch {
            if let v1Config = try? decoder.decode(ConfigurationV1.self, from: configData) {
                return Configuration(v1Config: v1Config)
            } else {
                throw LocalizationError(message: "Unable to read `localization.json` - " + error.localizedDescription)
            }
        }
    }

    /// Actually writes given `rows` to given `file`
    private func writeRows(_ rows: [LocRow], to file: String) throws {
        guard rows.count > 0 else { return }

        try checkDuplicateKeys(form: rows)

        try fileSystem.writeString(
            rows.map { $0.localizableRow }.joined(separator: "\n"),
            toFile: file,
            atomically: true,
            encoding: .utf8
        )
    }

    /// Check if given `rows` have a duplicated keys
    public func checkDuplicateKeys(form rows: [LocRow]) throws {
        let keys = rows.map { $0.key }
        let uniqueKeys = Set(keys)

        if keys.count != uniqueKeys.count {
            let duplicates = Dictionary(grouping: rows, by: \.key)
                .filter { $1.count > 1 }.keys
            throw LocalizationError(message: "❌ Check your Google Spreadsheet, you have a duplicated keys: \(duplicates)")
        }
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
}

extension String {
    func removingSuffix(_ suffix: String) -> String {
        guard hasSuffix(suffix) else { return self }
        return String(dropLast(suffix.count))
    }
}

/// Prints warning
///
/// Simple solution for now, later on we might wanna use something bit more robust and testable
func warn(_ message: String) {
    print("⚠️", message)
}
