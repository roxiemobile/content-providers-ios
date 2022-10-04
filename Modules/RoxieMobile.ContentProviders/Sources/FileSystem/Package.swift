// swift-tools-version: 5.6

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
    targets: [
        .target(
            name: "ContentProvidersFileSystem",
            path: "Sources"
        ),
    ],
    swiftLanguageVersions: [.v5]
)
