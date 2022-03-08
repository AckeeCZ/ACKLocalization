// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ACKLocalization",
    platforms: [
        .macOS(.v10_15),
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "ACKLocalizationCore",
            targets: ["ACKLocalizationCore"]),
        .executable(
            name: "ACKLocalization",
            targets: ["ACKLocalization"]),
    ],
    dependencies: [
        .package(url:"https://github.com/vapor/jwt-kit", .upToNextMajor(from: "4.3.0")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "ACKLocalizationCore",
            dependencies: ["JWTKit"]),
        .target(
            name: "ACKLocalization",
            dependencies: ["ACKLocalizationCore"]),
        .testTarget(
            name: "ACKLocalizationCoreTests",
            dependencies: ["ACKLocalizationCore"]),
    ]
)
