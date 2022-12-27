// swift-tools-version: 5.7

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
            url: "https://github.com/roxiemobile-forks/GRDB.swift",
            exact: "5.26.1-patch.1"
        ),
        .package(
            url: "https://github.com/roxiemobile/swift-commons-ios",
            exact: "1.7.0"
        ),
        .package(
            url: "https://github.com/weichsel/ZIPFoundation",
            exact: "0.9.16"
        ),
    ],
    targets: [
        .target(
            name: "ContentProvidersSQLite",
            dependencies: [
                "ZIPFoundation",
                .product(name: "GRDB", package: "GRDB.swift"),
                .product(name: "SwiftCommonsExtensions", package: "swift-commons-ios"),
            ],
            path: "Sources"
        ),
    ],
    swiftLanguageVersions: [.v5]
)
