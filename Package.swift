// swift-tools-version: 5.6

import PackageDescription

// Swift Package Manager — Package
// @link https://docs.swift.org/package-manager/PackageDescription/PackageDescription.html

let package = Package(
    name: "ContentProviders",
    platforms: [
        .iOS(.v13),
    ],
    products: [
        .library(
            name: "ContentProviders",
            type: .static,
            targets: ["ContentProviders"]
        ),

        .library(
            name: "ContentProvidersFileSystem",
            type: .static,
            targets: ["ContentProvidersFileSystem"]
        ),
        .library(
            name: "ContentProvidersSQLite",
            type: .static,
            targets: ["ContentProvidersSQLite"]
        ),
        .library(
            name: "ContentProvidersUserDefaults",
            type: .static,
            targets: ["ContentProvidersUserDefaults"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/roxiemobile-forks/GRDB.swift",
            exact: "5.21.0-patch.1"
        ),
        .package(
            url: "https://github.com/roxiemobile/swift-commons-ios",
            exact: "1.7.0"
        ),
        .package(
            url: "https://github.com/weichsel/ZIPFoundation",
            exact: "0.9.14"
        ),
    ],
    targets: [
        .target(
            name: "ContentProviders",
            dependencies: [
                .target(name: "ContentProvidersFileSystem"),
                .target(name: "ContentProvidersSQLite"),
                .target(name: "ContentProvidersUserDefaults"),
            ]
        ),

        .target(
            name: "ContentProvidersFileSystem",
            path: "Modules/RoxieMobile.ContentProviders/Sources/FileSystem/Sources"
        ),
        .target(
            name: "ContentProvidersSQLite",
            dependencies: [
                "ZIPFoundation",
                .product(name: "GRDB", package: "GRDB.swift"),
                .product(name: "SwiftCommonsExtensions", package: "swift-commons-ios"),
            ],
            path: "Modules/RoxieMobile.ContentProviders/Sources/SQLite/Sources"
        ),
        .target(
            name: "ContentProvidersUserDefaults",
            path: "Modules/RoxieMobile.ContentProviders/Sources/UserDefaults/Sources"
        ),
    ],
    swiftLanguageVersions: [.v5]
)
