// swift-tools-version:6.0

import PackageDescription

let package = Package(
    name: "ACKLocalization",
    platforms: [
        .macOS(.v13),
    ],
    products: [
        .library(
            name: "ACKLocalizationCore",
            targets: ["ACKLocalizationCore"]),
        .library(
            name: "ACKLocalizationCommands",
            targets: ["ACKLocalizationCommands"]),
        .executable(
            name: "ACKLocalization",
            targets: ["ACKLocalization"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/olejnjak/google-auth-swift",
            from: "0.1.1"
        ),
        .package(
            url: "https://github.com/apple/swift-argument-parser",
            from: "1.8.2"
        ),
    ],
    targets: [
        .target(
            name: "ACKLocalizationCore",
            dependencies: [
                .product(
                    name: "GoogleAuth",
                    package: "google-auth-swift"
                ),
            ]
        ),
        .target(
            name: "ACKLocalizationCommands",
            dependencies: [
                "ACKLocalizationCore",
                .product(
                    name: "ArgumentParser",
                    package: "swift-argument-parser"
                ),
            ]
        ),
        .executableTarget(
            name: "ACKLocalization",
            dependencies: ["ACKLocalizationCommands"]),
        .testTarget(
            name: "ACKLocalizationCoreTests",
            dependencies: ["ACKLocalizationCore"]),
    ],
    swiftLanguageModes: [.v5]
)
