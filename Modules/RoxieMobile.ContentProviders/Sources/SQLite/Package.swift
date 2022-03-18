// swift-tools-version:5.3

import PackageDescription

// Swift Package Manager — Package
// @link https://docs.swift.org/package-manager/PackageDescription/PackageDescription.html

let package = Package(
    name: "ContentProviders.SQLite",
    platforms: [
        .iOS(.v12),
    ],
    products: [
        .library(
            name: "ContentProvidersSQLite",
            type: .static,
            targets: [
                "ContentProvidersSQLite",
            ]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/krzyzanowskim/CryptoSwift",
            .upToNextMinor(from: "1.4.3")
        ),
        .package(
            name: "GRDB",
            url: "https://github.com/roxiemobile-forks/GRDB.swift",
            .exact("5.7.4-patch.1")
        ),
        .package(
            name: "SwiftCommons",
            url: "https://github.com/roxiemobile/swift-commons.ios",
            .upToNextMinor(from: "1.6.0")
        ),
        .package(
            url: "https://github.com/weichsel/ZIPFoundation",
            .upToNextMinor(from: "0.9.12")
        ),
    ],
    targets: [
        .target(
            name: "ContentProvidersSQLite",
            dependencies: [
                .byName(name: "CryptoSwift"),
                .byName(name: "GRDB"),
                .byName(name: "ZIPFoundation"),
                .product(name: "SwiftCommonsExtensions", package: "SwiftCommons"),
            ],
            path: "Sources"
        ),
    ],
    swiftLanguageVersions: [.v5]
)
