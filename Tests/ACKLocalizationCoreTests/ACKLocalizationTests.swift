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

    func test_valueRange_decodesIntegerCellValues() throws {
        let json = #"{"values":[["key","en"],["some_key",42]]}"#
        let valueRange = try JSONDecoder().decode(ValueRange.self, from: Data(json.utf8))
        XCTAssertEqual(valueRange.values, [["key", "en"], ["some_key", "42"]])
    }

    func test_valueRange_decodesDoubleCellValues() throws {
        let json = #"{"values":[["key","en"],["price_key",3.14]]}"#
        let valueRange = try JSONDecoder().decode(ValueRange.self, from: Data(json.utf8))
        XCTAssertEqual(valueRange.values, [["key", "en"], ["price_key", "3.14"]])
    }

    func test_valueRange_decodesMixedCellValues() throws {
        let json = #"{"values":[["key","en"],["str_key","hello"],["int_key",7]]}"#
        let valueRange = try JSONDecoder().decode(ValueRange.self, from: Data(json.utf8))
        XCTAssertEqual(valueRange.values, [["key", "en"], ["str_key", "hello"], ["int_key", "7"]])
    }

    func test_transform_integerCellValue() throws {
        let json = #"{"values":[["keys","en"],["count",42]]}"#
        let valueRange = try JSONDecoder().decode(ValueRange.self, from: Data(json.utf8))
        let mappedValues = try localization.transformValues(
            valueRange,
            with: ["en": "en"],
            keyColumnName: "keys"
        )
        XCTAssertEqual(
            mappedValues["en"],
            [LocRow(key: "count", value: "42")]
        )
    }
}
