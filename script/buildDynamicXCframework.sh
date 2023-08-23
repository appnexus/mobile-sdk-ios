#!/bin/bash
# buildxcframework.sh
#    The AppNexusSDK.xcframework and AppNexusNativeSDK.xcframework are built using the script file.
#     These instructions will create a zip file named AppNexusSDK.xcframework.zip that contains three frameworks: AppNexusSDK.xcframework, OMSDK_Appnexus.xcframework, and AppNexusNativeSDK.xcframework.
#     The AppNexusSDK.xcframework with OMSDK_Appnexus.xcframework or AppNexusNativeSDK.xcframework framework with OMSDK_Appnexus can be used in any combination.
#     iphoneos archive, or iphonesimulator archive will be used to generate the xcframework.
#     All temporary binaries will be removed using rm commands once the xcframework has been produced and the zip has been created.



# Output directory name
OUTDIR=$1+"Framework"
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

#mv ../XCFramework/OMSDK-Static_Appnexus.xcframework ../XCFramework/OMSDK_Appnexus.xcframework


# Move to XCFramework folder

cd ../XCFramework
##
## create zip with name AppNexusSDK.xcframework.zip which included   AppNexusSDK.xcframework OMSDK_Appnexus.xcframework and AppNexusNativeSDK.xcframework
zip -r ../$SCHEMENAME.xcframework.zip *

cd ..

rm -rf ./XCFramework

