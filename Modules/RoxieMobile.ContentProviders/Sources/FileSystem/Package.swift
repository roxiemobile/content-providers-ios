// swift-tools-version: 5.7

import PackageDescription

// Swift Package Manager — Package
// @link https://docs.swift.org/package-manager/PackageDescription/PackageDescription.html

let package = Package(
    name: "ContentProviders.FileSystem",
    platforms: [
        .iOS(.v13),
    ],
    products: [
        .library(
            name: "ContentProvidersFileSystem",
            type: .static,
            targets: [
                "ContentProvidersFileSystem",
            ]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/roxiemobile/swift-commons-ios",
            exact: "1.7.0"
        ),
    ],
    targets: [
        .target(
            name: "ContentProvidersFileSystem",
            dependencies: [
                .product(name: "SwiftCommonsExtensions", package: "swift-commons-ios"),
            ],
            path: "",
            sources: [
                "Dependencies",
                "Sources",
            ]
        ),
    ],
    swiftLanguageVersions: [.v5]
)
