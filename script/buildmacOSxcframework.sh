#!/bin/bash
# buildxcframework.sh
#	The AppNexusNativeMacOSSDK.xcframework are built using the script file.
# 	These instructions will create AppNexusNativeMacOSSDK.xcframework.
# 	macOS archive will be used to generate the xcframework.
# 	All temporary binaries will be removed using rm commands once the xcframework has been produced and the zip has been created.


# Output directory name
#Start Building AppNexusNativeMacOSSDK.xcframework

xcodebuild archive \
-scheme AppNexusNativeMacOSSDK \
-destination "generic/platform=OS X" \
-archivePath ../output/AppNexusNativeMacOSSDK-macOS \
SKIP_INSTALL=NO \
BUILD_LIBRARY_FOR_DISTRIBUTION=YES

 # Build XCFramework for using macOS archive
 xcodebuild -create-xcframework \
    -framework ../output/AppNexusNativeMacOSSDK-macOS.xcarchive/Products/Library/Frameworks/AppNexusNativeMacOSSDK.framework \
   -output ./../XCFramework/AppNexusNativeMacOSSDK.xcframework
   
rm -rf ../output
