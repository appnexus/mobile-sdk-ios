#!/bin/bash
# buildmacOSxcframework.sh
# From inside /app_mobile-sdk-ios/sdk(where the AppNexusSDK.xcodeproj file is present) you can run the below commands
# sh ../script/buildmacOSxcframework.sh

#	The AppNexusNativeMacOSSDK.xcframework.zip is built using the script file.
# 	These instructions will create a zip file named AppNexusNativeMacOSSDK.xcframework.zip that contains : AppNexusNativeMacOSSDK.xcframework
# 	macOS archive will be used to generate the AppNexusNativeMacOSSDK.xcframework.
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

# Move to XCFramework folder
cd ../XCFramework

##
## create zip with name AppNexusNativeMacOSSDK.xcframework.zip
zip -r ../AppNexusNativeMacOSSDK.xcframework.zip *

# Remove all temporary binaries
cd ..
rm -rf ./XCFramework