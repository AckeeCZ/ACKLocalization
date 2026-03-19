import Testing
@testable import ACKLocalizationCore

@Suite
struct LocRowTests {
    @Test
    func basicRow() {
        let locRow = LocRow(key: "key", value: "value")
        #expect(#""key" = "value";"# == locRow.localizableRow)
    }

    @Test
    func integerRow() {
        let locRow = LocRow(key: "int_key", value: "int value %d")
        #expect(#""int_key" = "int value %d";"# == locRow.localizableRow)
    }

    @Test
    func alternativeIntegerRow() {
        let locRow = LocRow(key: "int_key", value: "int value %i")
        #expect(#""int_key" = "int value %i";"# == locRow.localizableRow)
    }

    @Test
    func floatRow() {
        let locRow = LocRow(key: "float_key", value: "float value %f")
        #expect(#""float_key" = "float value %f";"# == locRow.localizableRow)
    }

    @Test
    func oneDecimalFloatRow() {
        let locRow = LocRow(key: "float_key", value: "float value with one decimal %.1f")
        #expect(#""float_key" = "float value with one decimal %.1f";"# == locRow.localizableRow)
    }

    @Test
    func threeDecimalFloatRow() {
        let locRow = LocRow(key: "float_key", value: "float value with three decimals %.3f")
        #expect(#""float_key" = "float value with three decimals %.3f";"# == locRow.localizableRow)
    }

    @Test
    func stringRow() {
        let locRow = LocRow(key: "string_key", value: "string value %s")
        #expect(#""string_key" = "string value %@";"# == locRow.localizableRow)
    }

    @Test
    func cocoaStringRow() {
        let locRow = LocRow(key: "string_key", value: "string value %@")
        #expect(#""string_key" = "string value %@";"# == locRow.localizableRow)
    }

    @Test
    func percentIsEscaped() {
        let locRow = LocRow(key: "percent_key", value: "%d % percent")
        #expect(#""percent_key" = "%d %% percent";"# == locRow.localizableRow)
    }

    @Test
    func keyQuotesAreEscaped() {
        let locRow = LocRow(key: "abc\"abc", value: "quotes_value")
        #expect(#""abc\"abc" = "quotes_value";"# == locRow.localizableRow)
    }

    @Test
    func valueQuotesAreEscaped() {
        let locRow = LocRow(key: "quotes_key", value: "abc\"abc")
        #expect(#""quotes_key" = "abc\"abc";"# == locRow.localizableRow)
    }

    @Test
    func newLineIsEscaped() {
        let locRow = LocRow(key: "nl_key", value: "abc\nabc")
        #expect(#""nl_key" = "abc\nabc";"# == locRow.localizableRow)
    }

    @Test
    func intPositionArgumentsAreReplaced() {
        let locRow = LocRow(key: "pos_arg_key", value: "%1$d people will arrive in %2$d minutes")
        #expect(#""pos_arg_key" = "%1$d people will arrive in %2$d minutes";"# == locRow.localizableRow)
    }

    @Test
    func floatPositionArgumentsAreReplaced() {
        let locRow = LocRow(key: "pos_arg_key", value: "%1$f people will arrive in %2$f minutes")
        #expect(#""pos_arg_key" = "%1$f people will arrive in %2$f minutes";"# == locRow.localizableRow)
    }

    @Test
    func stringPositionArgumentsAreReplaced() {
        let locRow = LocRow(key: "pos_arg_key", value: "%1$s people will arrive in %2$s minutes")
        #expect(#""pos_arg_key" = "%1$@ people will arrive in %2$@ minutes";"# == locRow.localizableRow)
    }

    @Test
    func cocoaStringPositionArgumentsAreReplaced() {
        let locRow = LocRow(key: "pos_arg_key", value: "%1$@ people will arrive in %2$@ minutes")
        #expect(#""pos_arg_key" = "%1$@ people will arrive in %2$@ minutes";"# == locRow.localizableRow)
    }
}
