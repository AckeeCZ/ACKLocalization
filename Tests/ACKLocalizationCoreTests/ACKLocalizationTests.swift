import Foundation
@testable import ACKLocalizationCore
import Testing

@Suite
struct ACKLocalizationTests {
    let localization = ACKLocalization()

    @Test
    func transformEmptyRow() throws {
        let mappedValues = try localization.transformValues(
            .init(
                values: [
                    ["keys", "cs"],
                    ["key"]
                ]
            ),
            with: ["cs": "cs"],
            keyColumnName: "keys"
        )

        #expect(Array(mappedValues.keys) == ["cs"])
        #expect(
            mappedValues.values.flatMap { $0 }
            == [LocRow(key: "key", value: "")]
        )
    }

    @Test
    func forDuplicateKeys() throws {
        let locRow = [
            LocRow(key: "key_1", value: "value1"),
            LocRow(key: "key_1", value: "value2"),
            LocRow(key: "key_2", value: "value3")
        ]
        #expect(throws: (any Error).self) {
            try localization.checkDuplicateKeys(form: locRow)
        }
    }

    @Test
    func forUniqueKeys() throws {
        let locRow = [
            LocRow(key: "key_1", value: "value1"),
            LocRow(key: "key_2", value: "value2"),
            LocRow(key: "key_3", value: "value3")
        ]
        #expect(throws: Never.self) {
            try localization.checkDuplicateKeys(form: locRow)
        }
    }

    @Test
    func removingSuffix() {
        let fileName = "Localizable.strings"
        #expect("Localizable" == fileName.removingSuffix(".strings"))
    }

    @Test
    func valueRangeDecodesIntegerCellValues() throws {
        let json = #"{"values":[["key","en"],["some_key",42]]}"#
        let valueRange = try JSONDecoder().decode(ValueRange.self, from: Data(json.utf8))
        #expect(valueRange.values == [["key", "en"], ["some_key", "42"]])
    }

    @Test
    func valueRangeDecodesDoubleCellValues() throws {
        let json = #"{"values":[["key","en"],["price_key",3.14]]}"#
        let valueRange = try JSONDecoder().decode(ValueRange.self, from: Data(json.utf8))
        #expect(valueRange.values == [["key", "en"], ["price_key", "3.14"]])
    }

    @Test
    func valueRangeDecodesMixedCellValues() throws {
        let json = #"{"values":[["key","en"],["str_key","hello"],["int_key",7]]}"#
        let valueRange = try JSONDecoder().decode(ValueRange.self, from: Data(json.utf8))
        #expect(valueRange.values == [["key", "en"], ["str_key", "hello"], ["int_key", "7"]])
    }

    @Test
    func transformIntegerCellValue() throws {
        let json = #"{"values":[["keys","en"],["count",42]]}"#
        let valueRange = try JSONDecoder().decode(ValueRange.self, from: Data(json.utf8))
        let mappedValues = try localization.transformValues(
            valueRange,
            with: ["en": "en"],
            keyColumnName: "keys"
        )
        #expect(
            mappedValues["en"]
            == [LocRow(key: "count", value: "42")]
        )
    }

    // MARK: - transformValues: multiple languages

    @Test
    func transformMultipleLanguages() throws {
        let mappedValues = try localization.transformValues(
            .init(values: [
                ["keys", "cs", "en"],
                ["greeting", "Ahoj", "Hello"],
                ["farewell", "Sbohem", "Goodbye"]
            ]),
            with: ["cs": "cs", "en": "en"],
            keyColumnName: "keys"
        )

        #expect(mappedValues.keys.count == 2)
        #expect(mappedValues["cs"] == [
            LocRow(key: "greeting", value: "Ahoj"),
            LocRow(key: "farewell", value: "Sbohem")
        ])
        #expect(mappedValues["en"] == [
            LocRow(key: "greeting", value: "Hello"),
            LocRow(key: "farewell", value: "Goodbye")
        ])
    }

    @Test
    func transformMissingKeyColumn() throws {
        #expect(throws: LocalizationError.self) {
            try localization.transformValues(
                .init(values: [
                    ["id", "cs"],
                    ["key", "value"]
                ]),
                with: ["cs": "cs"],
                keyColumnName: "keys"
            )
        }
    }

    @Test
    func transformHeaderOnly() throws {
        let mappedValues = try localization.transformValues(
            .init(values: [["keys", "cs"]]),
            with: ["cs": "cs"],
            keyColumnName: "keys"
        )

        #expect(mappedValues.isEmpty)
    }

    @Test
    func transformSkipsEmptyKeys() throws {
        let mappedValues = try localization.transformValues(
            .init(values: [
                ["keys", "en"],
                ["", "should be skipped"],
                ["valid_key", "kept"]
            ]),
            with: ["en": "en"],
            keyColumnName: "keys"
        )

        #expect(mappedValues["en"] == [LocRow(key: "valid_key", value: "kept")])
    }

    @Test
    func transformIgnoresUnmappedColumns() throws {
        let mappedValues = try localization.transformValues(
            .init(values: [
                ["keys", "cs", "en", "notes"],
                ["key1", "česky", "english", "some note"]
            ]),
            with: ["cs": "cs"],
            keyColumnName: "keys"
        )

        #expect(mappedValues.keys.count == 1)
        #expect(mappedValues["cs"] == [LocRow(key: "key1", value: "česky")])
    }

    @Test
    func transformMappingColumnNotInSheet() throws {
        let mappedValues = try localization.transformValues(
            .init(values: [
                ["keys", "cs"],
                ["key1", "česky"]
            ]),
            with: ["cs": "cs", "de": "de"],
            keyColumnName: "keys"
        )

        // "cs" should be mapped, "de" column doesn't exist so no rows for it
        #expect(mappedValues["cs"] == [LocRow(key: "key1", value: "česky")])
        #expect(mappedValues["de"] == nil)
    }

    @Test
    func transformRowShorterThanHeader() throws {
        let mappedValues = try localization.transformValues(
            .init(values: [
                ["keys", "cs", "en"],
                ["key1", "česky"],  // missing "en" column value
                ["key2", "česky2", "english2"]
            ]),
            with: ["cs": "cs", "en": "en"],
            keyColumnName: "keys"
        )

        #expect(mappedValues["cs"] == [
            LocRow(key: "key1", value: "česky"),
            LocRow(key: "key2", value: "česky2")
        ])
        #expect(mappedValues["en"] == [
            LocRow(key: "key1", value: ""),
            LocRow(key: "key2", value: "english2")
        ])
    }

    // MARK: - removingSuffix edge cases

    @Test
    func removingSuffixNoMatch() {
        let fileName = "Localizable"
        #expect("Localizable" == fileName.removingSuffix(".strings"))
    }

    @Test
    func removingSuffixMultipleDots() {
        let fileName = "My.Custom.strings"
        #expect("My.Custom" == fileName.removingSuffix(".strings"))
    }

    // MARK: - checkDuplicateKeys edge cases

    @Test
    func forEmptyRows() throws {
        #expect(throws: Never.self) {
            try localization.checkDuplicateKeys(form: [])
        }
    }

    @Test
    func forSingleRow() throws {
        #expect(throws: Never.self) {
            try localization.checkDuplicateKeys(form: [
                LocRow(key: "only_key", value: "value")
            ])
        }
    }
}
