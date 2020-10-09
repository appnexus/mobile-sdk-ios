// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AppNexusSDK",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v9),
    ],
    products: [
        .library(
            name: "AppNexusSDK",
            targets: [
                "AppNexusSDK",
                "OMSDK_Appnexus"
            ]
        ),
    ],
    targets: [
        .binaryTarget(
            name: "OMSDK_Appnexus",
            path: "sdk/sourcefiles/Viewability/OMSDK_Appnexus.xcframework"
        ),
        .target(
            name: "AppNexusSDK",
            dependencies: [],
            path: "./sdk/sourcefiles",
            exclude: [
                "Resources/Info.plist",
                "Viewability/OMSDK_Appnexus.framework",
                "Viewability/OMSDK_Appnexus.xcframework"
            ],
            resources: [
                .process("./Resources")
            ],
            publicHeadersPath: "./swiftpm-support",
            cSettings: [
                .headerSearchPath("../"),
            ]
        )
    ]
)
