import Foundation
import Testing
@testable import ACKLocalizationCore

@Suite
struct SaveMappedValuesTests {
    private let localization: ACKLocalization
    private let sheetsAPI: SheetsAPIServiceMock

    init() {
        sheetsAPI = SheetsAPIServiceMock()
        localization = ACKLocalization(sheetsAPI: sheetsAPI)
    }

    // MARK: - File writing

    @Test
    func writesStringsFile() throws {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: tempDir) }

        let destPath = tempDir.path

        let mappedValues: MappedValues = [
            "en": [
                LocRow(key: "greeting", value: "Hello"),
                LocRow(key: "farewell", value: "Goodbye")
            ]
        ]

        try localization.saveMappedValues(
            mappedValues,
            defaultFileName: "Localizable",
            destinations: ["Localizable": destPath]
        )

        let stringsPath = tempDir
            .appendingPathComponent("en.lproj")
            .appendingPathComponent("Localizable.strings")
            .path

        #expect(FileManager.default.fileExists(atPath: stringsPath))

        let content = try String(contentsOfFile: stringsPath, encoding: .utf8)
        #expect(content.contains(#""greeting" = "Hello";"#))
        #expect(content.contains(#""farewell" = "Goodbye";"#))
    }

    @Test
    func createsLprojDirectories() throws {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: tempDir) }

        let mappedValues: MappedValues = [
            "en": [LocRow(key: "key", value: "en_value")],
            "cs": [LocRow(key: "key", value: "cs_value")]
        ]

        try localization.saveMappedValues(
            mappedValues,
            defaultFileName: "Localizable",
            destinations: ["Localizable": tempDir.path]
        )

        let enDir = tempDir.appendingPathComponent("en.lproj").path
        let csDir = tempDir.appendingPathComponent("cs.lproj").path

        #expect(FileManager.default.fileExists(atPath: enDir))
        #expect(FileManager.default.fileExists(atPath: csDir))
    }

    @Test
    func writesStringsDictForPlurals() throws {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: tempDir) }

        let mappedValues: MappedValues = [
            "en": [
                LocRow(key: "items##{one}", value: "%d item"),
                LocRow(key: "items##{other}", value: "%d items")
            ]
        ]

        try localization.saveMappedValues(
            mappedValues,
            defaultFileName: "Localizable",
            destinations: ["Localizable": tempDir.path]
        )

        let stringsDictPath = tempDir
            .appendingPathComponent("en.lproj")
            .appendingPathComponent("Localizable.stringsdict")
            .path

        #expect(FileManager.default.fileExists(atPath: stringsDictPath))

        // .strings should NOT exist since all rows are plurals
        let stringsPath = tempDir
            .appendingPathComponent("en.lproj")
            .appendingPathComponent("Localizable.strings")
            .path

        #expect(!FileManager.default.fileExists(atPath: stringsPath))
    }

    @Test
    func separatesPluralsFromRegularKeys() throws {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: tempDir) }

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
            destinations: ["Localizable": tempDir.path]
        )

        let stringsPath = tempDir
            .appendingPathComponent("en.lproj")
            .appendingPathComponent("Localizable.strings")
            .path
        let stringsDictPath = tempDir
            .appendingPathComponent("en.lproj")
            .appendingPathComponent("Localizable.stringsdict")
            .path

        #expect(FileManager.default.fileExists(atPath: stringsPath))
        #expect(FileManager.default.fileExists(atPath: stringsDictPath))

        let stringsContent = try String(contentsOfFile: stringsPath, encoding: .utf8)
        #expect(stringsContent.contains(#""greeting" = "Hello";"#))
        #expect(!stringsContent.contains("items"))
    }

    // MARK: - Plist prefix routing

    @Test
    func plistPrefixRoutesToSeparateFile() throws {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: tempDir) }

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
                "Localizable": tempDir.path,
                "InfoPlist": tempDir.path
            ]
        )

        let localizablePath = tempDir
            .appendingPathComponent("en.lproj")
            .appendingPathComponent("Localizable.strings")
            .path
        let infoPlistPath = tempDir
            .appendingPathComponent("en.lproj")
            .appendingPathComponent("InfoPlist.strings")
            .path

        #expect(FileManager.default.fileExists(atPath: localizablePath))
        #expect(FileManager.default.fileExists(atPath: infoPlistPath))

        let localizableContent = try String(contentsOfFile: localizablePath, encoding: .utf8)
        #expect(localizableContent.contains(#""greeting" = "Hello";"#))

        let infoPlistContent = try String(contentsOfFile: infoPlistPath, encoding: .utf8)
        #expect(infoPlistContent.contains(#""CFBundleDisplayName" = "My App";"#))
    }

    @Test
    func plistPrefixStripsKeyPrefix() throws {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: tempDir) }

        let mappedValues: MappedValues = [
            "en": [
                LocRow(key: "plist.InfoPlist.NSCameraUsageDescription", value: "Camera needed")
            ]
        ]

        try localization.saveMappedValues(
            mappedValues,
            defaultFileName: "Localizable",
            destinations: [
                "Localizable": tempDir.path,
                "InfoPlist": tempDir.path
            ]
        )

        let infoPlistPath = tempDir
            .appendingPathComponent("en.lproj")
            .appendingPathComponent("InfoPlist.strings")
            .path

        let content = try String(contentsOfFile: infoPlistPath, encoding: .utf8)
        // The key should be "NSCameraUsageDescription", not "plist.InfoPlist.NSCameraUsageDescription"
        #expect(content.contains(#""NSCameraUsageDescription" = "Camera needed";"#))
        #expect(!content.contains("plist.InfoPlist"))
    }

    // MARK: - Default file name suffix stripping

    @Test
    func defaultFileNameStripsStringsSuffix() throws {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: tempDir) }

        let mappedValues: MappedValues = [
            "en": [LocRow(key: "key", value: "value")]
        ]

        try localization.saveMappedValues(
            mappedValues,
            defaultFileName: "Localizable.strings",
            destinations: ["Localizable": tempDir.path]
        )

        let stringsPath = tempDir
            .appendingPathComponent("en.lproj")
            .appendingPathComponent("Localizable.strings")
            .path

        #expect(FileManager.default.fileExists(atPath: stringsPath))
    }

    // MARK: - Duplicate keys

    @Test
    func duplicateKeysThrowsOnSave() throws {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: tempDir) }

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
                destinations: ["Localizable": tempDir.path]
            )
        }
    }

    // MARK: - Empty mapped values

    @Test
    func emptyMappedValuesDoesNotThrow() throws {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: tempDir) }

        #expect(throws: Never.self) {
            try localization.saveMappedValues(
                [:],
                defaultFileName: "Localizable",
                destinations: ["Localizable": tempDir.path]
            )
        }
    }
}
