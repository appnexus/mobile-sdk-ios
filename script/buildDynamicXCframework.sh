#!/bin/bash
# buildDynamicXCframework.sh
# You have to pass the Schema name as argument when you run the script for example:
# From inside /app_mobile-sdk-ios/sdk(where the AppNexusSDK.xcodeproj file is present) you can run the below commands
# sh ../script/buildDynamicXCframework.sh AppNexusSDK
# sh ../script/buildDynamicXCframework.sh AppNexusNativeSDK

#     The AppNexusSDK.xcframework.zip and AppNexusNativeSDK.xcframework.zip are built using the script file.
#     When run "AppNexusSDK" as the schema(argument), these instructions will create a zip file named AppNexusSDK.xcframework.zip that contains: AppNexusSDK.xcframework and OMSDK_Appnexus.xcframework.
#     When run "AppNexusNativeSDK" as the schema(argument), these instructions will create a zip file named AppNexusNativeSDK.xcframework.zip that contains: AppNexusNativeSDK.xcframework and OMSDK_Appnexus.xcframework.
#     iphoneos archive and iphonesimulator archive will be used to generate the xcframework.
#     All temporary binaries will be removed using rm commands once the xcframework has been produced and the zip has been created.



# Scheme name AppNexusSDK OR AppNexusNativeSDK
SCHEMENAME=$1

# Schema name for iPhones
OD_DEVICE="iphoneos"
# Schema name for simulator
OD_SIMULATOR="iphonesimulator"


# Build archive for iphonesimulator
xcodebuild archive \
 -scheme "$SCHEMENAME" \
 -archivePath ./"$OD_SIMULATOR"/"$SCHEMENAME"-"$OD_SIMULATOR".xcarchive \
 -sdk "$OD_SIMULATOR" \
 BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
 SKIP_INSTALL=NO

# Build archive for iphoneos
xcodebuild archive \
 -scheme "$SCHEMENAME" \
 -archivePath ./"$OD_DEVICE"/"$SCHEMENAME"-"$OD_DEVICE".xcarchive \
 -sdk "$OD_DEVICE" \
 BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
 SKIP_INSTALL=NO

 # Build XCFramework for using iphonesimulator and iphoneos archive
 xcodebuild -create-xcframework \
    -framework ./"$OD_SIMULATOR"/"$SCHEMENAME"-"$OD_SIMULATOR".xcarchive/Products/Library/Frameworks/"$SCHEMENAME".framework \
     -framework ./"$OD_DEVICE"/"$SCHEMENAME"-"$OD_DEVICE".xcarchive/Products/Library/Frameworks/"$SCHEMENAME".framework \
   -output ./../XCFramework/"$SCHEMENAME".xcframework

# Removed archive and output folder
rm -rf ./iphonesimulator
rm -rf ./iphoneos

# Copy OMSDK_Appnexus.xcframework from Viewability to XCFramework
cp -a "./sourcefiles/Viewability/dynamic_framework/OMSDK_Appnexus.xcframework" "../XCFramework"


# Move to XCFramework folder
cd ../XCFramework

##
## create zip with name $SCHEMENAME.xcframework.zip which included   $SCHEMENAME.xcframework OMSDK_Appnexus.xcframework
zip -r ../$SCHEMENAME.xcframework.zip *

# Remove all temporary binaries
cd ..
rm -rf ./XCFramework

