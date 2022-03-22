// swift-tools-version:5.5

import PackageDescription

// Swift Package Manager — Package
// @link https://docs.swift.org/package-manager/PackageDescription/PackageDescription.html

let package = Package(
    name: "ContentProviders.UserDefaults",
    platforms: [
        .iOS(.v12),
    ],
    products: [
        .library(
            name: "ContentProvidersUserDefaults",
            type: .static,
            targets: [
                "ContentProvidersUserDefaults",
            ]
        ),
    ],
    targets: [
        .target(
            name: "ContentProvidersUserDefaults",
            path: "Sources"
        ),
    ],
    swiftLanguageVersions: [.v5]
)
