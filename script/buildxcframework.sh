#!/bin/bash
# buildxcframework.sh
#	The AppNexusSDK.xcframework and AppNexusNativeSDK.xcframework are built using the script file.
# 	These instructions will create a zip file named AppNexusSDK.xcframework.zip that contains three frameworks: AppNexusSDK.xcframework, OMSDK_Appnexus.xcframework, and AppNexusNativeSDK.xcframework.
# 	The AppNexusSDK.xcframework with OMSDK_Appnexus.xcframework or AppNexusNativeSDK.xcframework framework with OMSDK_Appnexus can be used in any combination.
# 	iphoneos archive, or iphonesimulator archive will be used to generate the xcframework.
# 	All temporary binaries will be removed using rm commands once the xcframework has been produced and the zip has been created.

# Build Static Framework
sh ../script/buildStaticXCframework.sh

# Build Dynamic Framework
sh ../script/buildDynamicXCframework.sh AppNexusSDK

sh ../script/buildDynamicXCframework.sh AppNexusNativeSDK
