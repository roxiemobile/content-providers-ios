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
        .package(path: "FileSystem"),
        .package(
            url: "https://github.com/roxiemobile-forks/GRDB.swift",
            exact: "5.26.1-patch.1"
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
                .product(name: "ContentProvidersFileSystem", package: "FileSystem"),
                .product(name: "GRDB", package: "GRDB.swift"),
            ],
            path: "Sources"
        ),
    ],
    swiftLanguageVersions: [.v5]
)
