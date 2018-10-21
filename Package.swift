// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ACKLocalization",
    dependencies: [
        .package(url: "https://github.com/kylef/Commander.git", from: "0.8.0"),
        .package(url: "https://github.com/yaslab/CSV.swift.git", from: "2.1.0")
    ],
    targets: [
        .target(
            name: "Localization",
            dependencies: [
                "LocalizationCore"
            ]
        ),
        .target(
            name: "LocalizationCore",
            dependencies: [
                "Commander",
                "CSV"
            ]),
        .testTarget(
            name: "LocalizationCoreTests",
            dependencies: [
                "LocalizationCore"
            ]
        )
    ]
)
