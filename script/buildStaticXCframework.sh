#!/bin/bash
# buildStaticXCframework.sh
# From inside /app_mobile-sdk-ios/sdk(where the AppNexusSDK.xcodeproj file is present) you can run the below commands
# sh ../script/buildStaticXCframework.sh

#	The AppNexusNativeStaticSDK.xcframework.zip is built using the script file.
# 	These instructions will create a zip file named AppNexusNativeStaticSDK.xcframework.zip that contains : AppNexusNativeStaticSDK.xcframework and ANSDKResources.bundle.
# 	iphoneos archive and iphonesimulator archive will be used to generate the xcframework.
# 	All temporary binaries will be removed using rm commands once the xcframework has been produced and the zip has been created.


# Output directory name
#Start Building AppNexusSDK.xcframework

# Schema name for iPhones
OD_DEVICE="iphoneos"
# Schema name for simulator
OD_SIMULATOR="iphonesimulator"
#

# Schema name AppNexusNativeStaticSDK
STATICSCHEMANAME="AppNexusNativeStaticSDK"


# Build archive for iphonesimulator
xcodebuild archive \
 -scheme "$STATICSCHEMANAME" \
 -archivePath ./"$OD_SIMULATOR"/"$STATICSCHEMANAME"-"$OD_SIMULATOR".xcarchive \
 -sdk "$OD_SIMULATOR" \
 BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
 SKIP_INSTALL=NO

# Build archive for iphoneos
xcodebuild archive \
 -scheme "$STATICSCHEMANAME" \
 -archivePath ./"$OD_DEVICE"/"$STATICSCHEMANAME"-"$OD_DEVICE".xcarchive \
 -sdk "$OD_DEVICE" \
 BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
 SKIP_INSTALL=NO

 # Build XCFramework for using iphonesimulator and iphoneos archive
 xcodebuild -create-xcframework \
    -framework ./"$OD_SIMULATOR"/"$STATICSCHEMANAME"-"$OD_SIMULATOR".xcarchive/Products/Library/Frameworks/"$STATICSCHEMANAME".framework \
     -framework ./"$OD_DEVICE"/"$STATICSCHEMANAME"-"$OD_DEVICE".xcarchive/Products/Library/Frameworks/"$STATICSCHEMANAME".framework \
   -output ./../XCFramework/"$STATICSCHEMANAME".xcframework

# Removed archive and output folder
rm -rf ./iphonesimulator
rm -rf ./iphoneos

# Copy ANSDKResources.bundle to XCFramework



sh ../script/buildANSDKResourcesBundle.sh

cp -a "./ANSDKResources.bundle" "../XCFramework"
rm -rf ./ANSDKResources.bundle

# Move to XCFramework folder
cd ../XCFramework

## create a zip file named AppNexusNativeStaticSDK.xcframework.zip that contains : AppNexusNativeStaticSDK.xcframework and ANSDKResources.bundle.
zip -r ../AppNexusNativeStaticSDK.xcframework.zip *

# Remove all temporary binaries
cd ..
rm -rf ./XCFramework
