#!/bin/bash
# buildxcframework.sh
# From inside /app_mobile-sdk-ios/sdk(where the AppNexusSDK.xcodeproj file is present) you can run the below commands
# sh ../script/buildxcframework.sh

#	The AppNexusSDK.xcframework.zip, AppNexusNativeSDK.xcframework.zip and AppNexusNativeStaticSDK.xcframework.zip are built using the script file.
#   This is just an umbrella script used during release time to build all of the supported(both static and dynamic) XCFramework's for iphoneos and iphonesimulator

# Build Static Framework
sh ../script/buildStaticXCframework.sh

# Build Dynamic Framework
sh ../script/buildDynamicXCframework.sh AppNexusSDK

sh ../script/buildDynamicXCframework.sh AppNexusNativeSDK
