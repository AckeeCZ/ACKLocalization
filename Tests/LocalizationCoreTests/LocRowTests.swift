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
    
    func testAlternativeIntegerRow() {
        let locRow = LocRow(key: "int_key", value: "int value %i")
        XCTAssertEqual("\"int_key\" = \"int value %i\";", locRow.localizableRow)
    }
    
    func testFloatRow() {
        let locRow = LocRow(key: "float_key", value: "float value %f")
        XCTAssertEqual("\"float_key\" = \"float value %f\";", locRow.localizableRow)
    }
    
    func testStringRow() {
        let locRow = LocRow(key: "string_key", value: "string value %s")
        XCTAssertEqual("\"string_key\" = \"string value %@\";", locRow.localizableRow)
    }
    
    func testCocoaStringRow() {
        let locRow = LocRow(key: "string_key", value: "string value %@")
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
    
    func testIntPositionArgumentsAreReplaced() {
        let locRow = LocRow(key: "pos_arg_key", value: "%1$d people will arrive in %2$d minutes")
        XCTAssertEqual("\"pos_arg_key\" = \"%1$d people will arrive in %2$d minutes\";", locRow.localizableRow)
    }
    
    func testFloatPositionArgumentsAreReplaced() {
        let locRow = LocRow(key: "pos_arg_key", value: "%1$f people will arrive in %2$f minutes")
        XCTAssertEqual("\"pos_arg_key\" = \"%1$f people will arrive in %2$f minutes\";", locRow.localizableRow)
    }
    
    func testStringPositionArgumentsAreReplaced() {
        let locRow = LocRow(key: "pos_arg_key", value: "%1$s people will arrive in %2$s minutes")
        XCTAssertEqual("\"pos_arg_key\" = \"%1$@ people will arrive in %2$@ minutes\";", locRow.localizableRow)
    }
    
    func testCocoaStringPositionArgumentsAreReplaced() {
        let locRow = LocRow(key: "pos_arg_key", value: "%1$@ people will arrive in %2$@ minutes")
        XCTAssertEqual("\"pos_arg_key\" = \"%1$@ people will arrive in %2$@ minutes\";", locRow.localizableRow)
    }
}
