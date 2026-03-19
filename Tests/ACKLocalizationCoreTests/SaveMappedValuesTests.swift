import Foundation
import Testing
@testable import ACKLocalizationCore

@Suite
struct SaveMappedValuesTests {
    private let localization: ACKLocalization
    private let sheetsAPI: SheetsAPIServiceMock
    private let fileSystem: FileSystemMock

    init() {
        sheetsAPI = SheetsAPIServiceMock()
        fileSystem = FileSystemMock()
        localization = ACKLocalization(sheetsAPI: sheetsAPI, fileSystem: fileSystem)
    }

    // MARK: - File writing

    @Test
    func writesStringsFile() throws {
        let mappedValues: MappedValues = [
            "en": [
                LocRow(key: "greeting", value: "Hello"),
                LocRow(key: "farewell", value: "Goodbye")
            ]
        ]

        try localization.saveMappedValues(
            mappedValues,
            defaultFileName: "Localizable",
            destinations: ["Localizable": "/output"]
        )

        let stringsPath = "/output/en.lproj/Localizable.strings"

        #expect(fileSystem.writtenStrings[stringsPath] != nil)

        let content = fileSystem.writtenStrings[stringsPath]!
        #expect(content.contains(#""greeting" = "Hello";"#))
        #expect(content.contains(#""farewell" = "Goodbye";"#))
    }

    @Test
    func createsLprojDirectories() throws {
        let mappedValues: MappedValues = [
            "en": [LocRow(key: "key", value: "en_value")],
            "cs": [LocRow(key: "key", value: "cs_value")]
        ]

        try localization.saveMappedValues(
            mappedValues,
            defaultFileName: "Localizable",
            destinations: ["Localizable": "/output"]
        )

        #expect(fileSystem.createdDirectories.contains("/output/en.lproj"))
        #expect(fileSystem.createdDirectories.contains("/output/cs.lproj"))
    }

    @Test
    func writesStringsDictForPlurals() throws {
        let mappedValues: MappedValues = [
            "en": [
                LocRow(key: "items##{one}", value: "%d item"),
                LocRow(key: "items##{other}", value: "%d items")
            ]
        ]

        try localization.saveMappedValues(
            mappedValues,
            defaultFileName: "Localizable",
            destinations: ["Localizable": "/output"]
        )

        let stringsDictPath = "/output/en.lproj/Localizable.stringsdict"
        let stringsPath = "/output/en.lproj/Localizable.strings"

        #expect(fileSystem.writtenData[stringsDictPath] != nil)
        // .strings should NOT exist since all rows are plurals
        #expect(fileSystem.writtenStrings[stringsPath] == nil)
    }

    @Test
    func separatesPluralsFromRegularKeys() throws {
        let mappedValues: MappedValues = [
            "en": [
                LocRow(key: "greeting", value: "Hello"),
                LocRow(key: "items##{one}", value: "%d item"),
                LocRow(key: "items##{other}", value: "%d items")
            ]
        ]

        try localization.saveMappedValues(
            mappedValues,
            defaultFileName: "Localizable",
            destinations: ["Localizable": "/output"]
        )

        let stringsPath = "/output/en.lproj/Localizable.strings"
        let stringsDictPath = "/output/en.lproj/Localizable.stringsdict"

        #expect(fileSystem.writtenStrings[stringsPath] != nil)
        #expect(fileSystem.writtenData[stringsDictPath] != nil)

        let stringsContent = fileSystem.writtenStrings[stringsPath]!
        #expect(stringsContent.contains(#""greeting" = "Hello";"#))
        #expect(!stringsContent.contains("items"))
    }

    // MARK: - Plist prefix routing

    @Test
    func plistPrefixRoutesToSeparateFile() throws {
        let mappedValues: MappedValues = [
            "en": [
                LocRow(key: "greeting", value: "Hello"),
                LocRow(key: "plist.InfoPlist.CFBundleDisplayName", value: "My App")
            ]
        ]

        try localization.saveMappedValues(
            mappedValues,
            defaultFileName: "Localizable",
            destinations: [
                "Localizable": "/output",
                "InfoPlist": "/output"
            ]
        )

        let localizablePath = "/output/en.lproj/Localizable.strings"
        let infoPlistPath = "/output/en.lproj/InfoPlist.strings"

        #expect(fileSystem.writtenStrings[localizablePath] != nil)
        #expect(fileSystem.writtenStrings[infoPlistPath] != nil)

        let localizableContent = fileSystem.writtenStrings[localizablePath]!
        #expect(localizableContent.contains(#""greeting" = "Hello";"#))

        let infoPlistContent = fileSystem.writtenStrings[infoPlistPath]!
        #expect(infoPlistContent.contains(#""CFBundleDisplayName" = "My App";"#))
    }

    @Test
    func plistPrefixStripsKeyPrefix() throws {
        let mappedValues: MappedValues = [
            "en": [
                LocRow(key: "plist.InfoPlist.NSCameraUsageDescription", value: "Camera needed")
            ]
        ]

        try localization.saveMappedValues(
            mappedValues,
            defaultFileName: "Localizable",
            destinations: [
                "Localizable": "/output",
                "InfoPlist": "/output"
            ]
        )

        let infoPlistPath = "/output/en.lproj/InfoPlist.strings"

        let content = fileSystem.writtenStrings[infoPlistPath]!
        // The key should be "NSCameraUsageDescription", not "plist.InfoPlist.NSCameraUsageDescription"
        #expect(content.contains(#""NSCameraUsageDescription" = "Camera needed";"#))
        #expect(!content.contains("plist.InfoPlist"))
    }

    // MARK: - Default file name suffix stripping

    @Test
    func defaultFileNameStripsStringsSuffix() throws {
        let mappedValues: MappedValues = [
            "en": [LocRow(key: "key", value: "value")]
        ]

        try localization.saveMappedValues(
            mappedValues,
            defaultFileName: "Localizable.strings",
            destinations: ["Localizable": "/output"]
        )

        let stringsPath = "/output/en.lproj/Localizable.strings"
        #expect(fileSystem.writtenStrings[stringsPath] != nil)
    }

    // MARK: - Duplicate keys

    @Test
    func duplicateKeysThrowsOnSave() throws {
        let mappedValues: MappedValues = [
            "en": [
                LocRow(key: "key", value: "value1"),
                LocRow(key: "key", value: "value2")
            ]
        ]

        #expect(throws: (any Error).self) {
            try localization.saveMappedValues(
                mappedValues,
                defaultFileName: "Localizable",
                destinations: ["Localizable": "/output"]
            )
        }
    }

    // MARK: - Empty mapped values

    @Test
    func emptyMappedValuesDoesNotThrow() throws {
        #expect(throws: Never.self) {
            try localization.saveMappedValues(
                [:],
                defaultFileName: "Localizable",
                destinations: ["Localizable": "/output"]
            )
        }
    }
}
