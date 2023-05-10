// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AppNexusSDK",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v10),
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
        .package(name: "GoogleMobileAds", url: "https://github.com/googleads/swift-package-manager-google-mobile-ads.git", .exact("10.3.0"))
    ],
    targets: [
        .binaryTarget(
            name: "OMSDK_Appnexus",
            path: "sdk/sourcefiles/Viewability/OMSDK_Appnexus.xcframework"
        ),
        .target(
            name: "AppNexusSDK",
            dependencies: ["OMSDK_Appnexus"],
            path: "sdk/sourcefiles",
            exclude: [
                "Resources/Info.plist",
                "Viewability/OMSDK_Appnexus.xcframework",
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
