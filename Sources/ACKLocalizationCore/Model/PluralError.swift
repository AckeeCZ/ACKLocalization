import Foundation

public enum PluralError: Error, Equatable {
    case missingTranslationKey(String)
    case missingPluralRule(String)
    case invalidPluralRule(String)
}
