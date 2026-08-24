import Foundation
import Testing
@testable import ACKLocalizationCore

@Suite
struct ValueRangeTests {
    // MARK: - firstIndex(columnName:)

    @Test
    func firstIndexFindsColumn() {
        let range = ValueRange(values: [["keys", "cs", "en"]])

        #expect(range.firstIndex(columnName: "keys") == 0)
        #expect(range.firstIndex(columnName: "cs") == 1)
        #expect(range.firstIndex(columnName: "en") == 2)
    }

    @Test
    func firstIndexReturnsNilForMissingColumn() {
        let range = ValueRange(values: [["keys", "cs"]])

        #expect(range.firstIndex(columnName: "de") == nil)
    }

    @Test
    func firstIndexEmptyValues() {
        let range = ValueRange(values: [])

        #expect(range.firstIndex(columnName: "keys") == nil)
    }

    @Test
    func firstIndexEmptyHeaderRow() {
        let range = ValueRange(values: [[]])

        #expect(range.firstIndex(columnName: "keys") == nil)
    }

    // MARK: - Decoding edge cases

    @Test
    func decodesEmptyValues() throws {
        let json = #"{"values":[]}"#
        let valueRange = try JSONDecoder().decode(ValueRange.self, from: Data(json.utf8))

        #expect(valueRange.values.isEmpty)
    }

    @Test
    func decodesEmptyRow() throws {
        let json = #"{"values":[[]]}"#
        let valueRange = try JSONDecoder().decode(ValueRange.self, from: Data(json.utf8))

        #expect(valueRange.values == [[]])
    }

    @Test
    func decodesUnsupportedCellTypeAsEmpty() throws {
        // Boolean values are not handled by any specific case, should fall through to empty string
        let json = #"{"values":[["key", true]]}"#
        let valueRange = try JSONDecoder().decode(ValueRange.self, from: Data(json.utf8))

        #expect(valueRange.values == [["key", ""]])
    }

    @Test
    func decodesNegativeNumbers() throws {
        let json = #"{"values":[["key","en"],["count",-5]]}"#
        let valueRange = try JSONDecoder().decode(ValueRange.self, from: Data(json.utf8))

        #expect(valueRange.values[1] == ["count", "-5"])
    }

    // MARK: - Init with values

    @Test
    func initWithValues() {
        let range = ValueRange(values: [["a", "b"], ["c", "d"]])

        #expect(range.values == [["a", "b"], ["c", "d"]])
    }
}
