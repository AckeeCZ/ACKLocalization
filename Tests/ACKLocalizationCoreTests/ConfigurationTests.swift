import Foundation
import Testing
@testable import ACKLocalizationCore

@Suite
struct ConfigurationTests {
    private let decoder = JSONDecoder()

    // MARK: - V2 Configuration

    @Test
    func decodesV2Configuration() throws {
        let json = """
        {
            "spreadsheetID": "abc123",
            "keyColumnName": "keys",
            "languageMapping": {"cs": "cs", "en": "en"},
            "destinations": {"Localizable": "~/Project"},
            "defaultFileName": "Localizable"
        }
        """

        let config = try decoder.decode(Configuration.self, from: Data(json.utf8))

        #expect(config.spreadsheetID == "abc123")
        #expect(config.keyColumnName == "keys")
        #expect(config.languageMapping == ["cs": "cs", "en": "en"])
        #expect(config.destinations == ["Localizable": "~/Project"])
        #expect(config.defaultFileName == "Localizable")
        #expect(config.apiKey == nil)
        #expect(config.serviceAccount == nil)
        #expect(config.spreadsheetTabName == nil)
    }

    @Test
    func decodesV2WithAPIKey() throws {
        let json = """
        {
            "spreadsheetID": "abc123",
            "keyColumnName": "keys",
            "languageMapping": {"cs": "cs"},
            "destinations": {"Localizable": "~/Project"},
            "defaultFileName": "Localizable",
            "apiKey": "my-api-key"
        }
        """

        let config = try decoder.decode(Configuration.self, from: Data(json.utf8))

        #expect(config.apiKey?.value == "my-api-key")
    }

    @Test
    func decodesV2WithServiceAccount() throws {
        let json = """
        {
            "spreadsheetID": "abc123",
            "keyColumnName": "keys",
            "languageMapping": {"cs": "cs"},
            "destinations": {"Localizable": "~/Project"},
            "defaultFileName": "Localizable",
            "serviceAccount": "path/to/sa.json"
        }
        """

        let config = try decoder.decode(Configuration.self, from: Data(json.utf8))

        #expect(config.serviceAccount == "path/to/sa.json")
    }

    @Test
    func decodesV2WithSpreadsheetTabName() throws {
        let json = """
        {
            "spreadsheetID": "abc123",
            "keyColumnName": "keys",
            "languageMapping": {"cs": "cs"},
            "destinations": {"Localizable": "~/Project"},
            "defaultFileName": "Localizable",
            "spreadsheetTabName": "Translations"
        }
        """

        let config = try decoder.decode(Configuration.self, from: Data(json.utf8))

        #expect(config.spreadsheetTabName == "Translations")
    }

    @Test
    func v2MissingRequiredFieldThrows() {
        let json = """
        {
            "spreadsheetID": "abc123",
            "keyColumnName": "keys"
        }
        """

        #expect(throws: (any Error).self) {
            try decoder.decode(Configuration.self, from: Data(json.utf8))
        }
    }

    // MARK: - V1 → V2 Migration

    @Test
    func v1MigrationSetsDestinations() throws {
        let v1 = ConfigurationV1(
            apiKey: "test-key",
            destinationDir: "~/MyApp",
            keyColumnName: "keys",
            languageMapping: ["cs": "cs"],
            serviceAccount: nil,
            spreadsheetID: "sheet-id",
            spreadsheetTabName: nil,
            stringsFileName: nil,
            stringsDictFileName: nil
        )

        let v2 = Configuration(v1Config: v1)

        #expect(v2.defaultFileName == "Localizable")
        #expect(v2.destinations == ["Localizable": "~/MyApp"])
        #expect(v2.spreadsheetID == "sheet-id")
        #expect(v2.keyColumnName == "keys")
    }

    @Test
    func v1MigrationWithCustomStringsFileName() throws {
        let v1 = ConfigurationV1(
            apiKey: nil,
            destinationDir: "~/MyApp",
            keyColumnName: "keys",
            languageMapping: ["en": "en"],
            serviceAccount: "sa.json",
            spreadsheetID: "sheet-id",
            spreadsheetTabName: "Tab1",
            stringsFileName: "MyStrings.strings",
            stringsDictFileName: nil
        )

        let v2 = Configuration(v1Config: v1)

        #expect(v2.defaultFileName == "MyStrings")
        #expect(v2.destinations == ["MyStrings": "~/MyApp"])
        #expect(v2.serviceAccount == "sa.json")
        #expect(v2.spreadsheetTabName == "Tab1")
    }

    @Test
    func v1Decoding() throws {
        let json = """
        {
            "spreadsheetID": "abc123",
            "keyColumnName": "keys",
            "languageMapping": {"en": "en"},
            "destinationDir": "~/Project",
            "apiKey": "my-key"
        }
        """

        let config = try decoder.decode(ConfigurationV1.self, from: Data(json.utf8))

        #expect(config.spreadsheetID == "abc123")
        #expect(config.destinationDir == "~/Project")
        #expect(config.apiKey?.value == "my-key")
    }
}
