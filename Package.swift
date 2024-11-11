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
        .executable(
            name: "ACKLocalization",
            targets: ["ACKLocalization"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/olejnjak/google-auth-swift",
            from: "0.1.1"
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
        .executableTarget(
            name: "ACKLocalization",
            dependencies: ["ACKLocalizationCore"]),
        .testTarget(
            name: "ACKLocalizationCoreTests",
            dependencies: ["ACKLocalizationCore"]),
    ],
    swiftLanguageModes: [.v5]
)
