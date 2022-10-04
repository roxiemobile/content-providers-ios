// swift-tools-version: 5.6

import PackageDescription

// Swift Package Manager — Package
// @link https://docs.swift.org/package-manager/PackageDescription/PackageDescription.html

let package = Package(
    name: "ContentProviders.SQLite",
    platforms: [
        .iOS(.v13),
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
            exact: "1.4.3"
        ),
        .package(
            url: "https://github.com/roxiemobile-forks/GRDB.swift",
            exact: "5.21.0-patch.1"
        ),
        .package(
            url: "https://github.com/roxiemobile/swift-commons-ios",
            exact: "1.6.3"
        ),
        .package(
            url: "https://github.com/weichsel/ZIPFoundation",
            exact: "0.9.14"
        ),
    ],
    targets: [
        .target(
            name: "ContentProvidersSQLite",
            dependencies: [
                "CryptoSwift",
                "ZIPFoundation",
                .product(name: "GRDB", package: "GRDB.swift"),
                .product(name: "SwiftCommonsExtensions", package: "swift-commons-ios"),
            ],
            path: "Sources"
        ),
    ],
    swiftLanguageVersions: [.v5]
)
