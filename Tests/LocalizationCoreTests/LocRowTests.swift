import XCTest
@testable import LocalizationCore

final class LocRowTests: XCTestCase {
    func testBasicRow() {
        let locRow = LocRow(key: "key", value: "value")
        XCTAssertEqual("\"key\" = \"value\";", locRow.localizableRow)
    }
    
    func testIntegerRow() {
        let locRow = LocRow(key: "int_key", value: "int value %d")
        XCTAssertEqual("\"int_key\" = \"int value %d\";", locRow.localizableRow)
    }
    
    func testFloatRow() {
        let locRow = LocRow(key: "float_key", value: "float value %f")
        XCTAssertEqual("\"float_key\" = \"float value %f\";", locRow.localizableRow)
    }
    
    func testStringRow() {
        let locRow = LocRow(key: "string_key", value: "string value %s")
        XCTAssertEqual("\"string_key\" = \"string value %@\";", locRow.localizableRow)
    }
    
    func testPercentIsEscaped() {
        let locRow = LocRow(key: "percent_key", value: "%d % percent")
        XCTAssertEqual("\"percent_key\" = \"%d %% percent\";", locRow.localizableRow)
    }
    
    func testQuotesAreEscaped() {
        let locRow = LocRow(key: "quotes_key", value: "abc\"abc")
        XCTAssertEqual("\"quotes_key\" = \"abc\\\"abc\";", locRow.localizableRow)
    }
    
    func testNewLineIsEscaped() {
        let locRow = LocRow(key: "nl_key", value: "abc\nabc")
        XCTAssertEqual("\"nl_key\" = \"abc\\nabc\";", locRow.localizableRow)
    }
}
