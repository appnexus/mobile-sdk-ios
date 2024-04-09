// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AppNexusSDK",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v12),
    ],
    products: [
        .library(
            name: "AppNexusSDK",
            targets: [
                "AppNexusSDK",
            ]
        ),
        .library(
            name: "GoogleMediationAdapter",
            targets: [
                "GoogleMediationAdapter",
            ]
        ),
    ],
    dependencies: [
        .package(name: "GoogleMobileAds", url: "https://github.com/googleads/swift-package-manager-google-mobile-ads.git", .exact("11.2.0"))
    ],
    targets: [
        .binaryTarget(
            name: "OMSDK_Microsoft",
            path: "sdk/sourcefiles/Viewability/dynamic_framework/OMSDK_Microsoft.xcframework"
        ),
        .target(
            name: "AppNexusSDK",
            dependencies: ["OMSDK_Microsoft"],
            path: "sdk/sourcefiles",
            exclude: [
                "Resources/Info.plist",
                "Resources/ANSDKResources.bundle",
                "Viewability/dynamic_framework/OMSDK_Microsoft.xcframework",
                "Viewability/static_framework/OMSDK-Static_Microsoft.xcframework",
                "macOS/"
            ],
            resources: [
                .process("Resources")
            ],
            publicHeadersPath: "./public-headers",
            cSettings: [
                .headerSearchPath("./"),
                .headerSearchPath("./Categories"),
                .headerSearchPath("./internal"),
                .headerSearchPath("./internal/config"),
                .headerSearchPath("./internal/MRAID"),
                .headerSearchPath("./native"),
                .headerSearchPath("./native/internal"),
                .headerSearchPath("./native/internal/NativeRendering"),
                .headerSearchPath("./video"),
                .headerSearchPath("./Viewability"),
            ]
        ),
        .target(
            name: "GoogleMediationAdapter",
            dependencies: ["AppNexusSDK","GoogleMobileAds"],
            path: "mediation/mediatedviews/GoogleAdMob",
            cSettings: [
                .headerSearchPath("./"),
            ]
        )
    ]
)
