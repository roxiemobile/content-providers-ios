// swift-tools-version:5.3

import PackageDescription

// Swift Package Manager — Package
// @link https://docs.swift.org/package-manager/PackageDescription/PackageDescription.html

let package = Package(
    name: "ContentProviders",
    platforms: [
        .iOS(.v12),
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
            .upToNextMinor(from: "0.9.14")
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
                .byName(name: "CryptoSwift"),
                .byName(name: "GRDB"),
                .byName(name: "ZIPFoundation"),
                .product(name: "SwiftCommonsExtensions", package: "SwiftCommons"),
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
