#!/bin/bash
# buildxcframework.sh
#	The AppNexusSDK.xcframework and AppNexusNativeSDK.xcframework are built using the script file.
# 	These instructions will create a zip file named AppNexusSDK.xcframework.zip that contains three frameworks: AppNexusSDK.xcframework, OMSDK_Appnexus.xcframework, and AppNexusNativeSDK.xcframework.
# 	The AppNexusSDK.xcframework with OMSDK_Appnexus.xcframework or AppNexusNativeSDK.xcframework framework with OMSDK_Appnexus can be used in any combination.
# 	iphoneos archive, or iphonesimulator archive will be used to generate the xcframework.
# 	All temporary binaries will be removed using rm commands once the xcframework has been produced and the zip has been created.


# Output directory name
#Start Building AppNexusSDK.xcframework

# Schema name AppNexusSDK OR AppNexusNativeSDK
SCHEMANAME="AppNexusSDK"
# Schema name for iPhones
OD_DEVICE="iphoneos"
# Schema name for simulator
OD_SIMULATOR="iphonesimulator"


# Build archive for iphonesimulator
xcodebuild archive \
 -scheme "$SCHEMANAME" \
 -archivePath ./"$OD_SIMULATOR"/"$SCHEMANAME"-"$OD_SIMULATOR".xcarchive \
 -sdk "$OD_SIMULATOR" \
 BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
 SKIP_INSTALL=NO

# Build archive for iphoneos
xcodebuild archive \
 -scheme "$SCHEMANAME" \
 -archivePath ./"$OD_DEVICE"/"$SCHEMANAME"-"$OD_DEVICE".xcarchive \
 -sdk "$OD_DEVICE" \
 BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
 SKIP_INSTALL=NO
 
 # Build XCFramework for using iphonesimulator and iphoneos archive
 xcodebuild -create-xcframework \
    -framework ./"$OD_SIMULATOR"/"$SCHEMANAME"-"$OD_SIMULATOR".xcarchive/Products/Library/Frameworks/"$SCHEMANAME".framework \
     -framework ./"$OD_DEVICE"/"$SCHEMANAME"-"$OD_DEVICE".xcarchive/Products/Library/Frameworks/"$SCHEMANAME".framework \
   -output ./../XCFramework/"$SCHEMANAME".xcframework

# Zip XCFramework
#zip -r "$OUTDIR" ../XCFramework

# Removed archive and output folder
rm -rf ./iphonesimulator
rm -rf ./iphoneos
#rm -rf ./../XCFramework


SCHEMENAME_NATIVESDK="AppNexusNativeSDK"



# Build archive for iphonesimulator
xcodebuild archive \
 -scheme "$SCHEMANAME_NATIVESDK" \
 -archivePath ./"$OD_SIMULATOR"/"$SCHEMANAME_NATIVESDK"-"$OD_SIMULATOR".xcarchive \
 -sdk "$OD_SIMULATOR" \
 BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
 SKIP_INSTALL=NO



 # Build archive for iphoneos
xcodebuild archive \
 -scheme "$SCHEMANAME_NATIVESDK" \
 -archivePath ./"$OD_DEVICE"/"$SCHEMANAME_NATIVESDK"-"$OD_DEVICE".xcarchive \
 -sdk "$OD_DEVICE" \
 BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
 SKIP_INSTALL=NO
 
 # Build XCFramework for using iphonesimulator and iphoneos archive
 xcodebuild -create-xcframework \
    -framework ./"$OD_SIMULATOR"/"$SCHEMANAME_NATIVESDK"-"$OD_SIMULATOR".xcarchive/Products/Library/Frameworks/"$SCHEMANAME_NATIVESDK".framework \
     -framework ./"$OD_DEVICE"/"$SCHEMANAME_NATIVESDK"-"$OD_DEVICE".xcarchive/Products/Library/Frameworks/"$SCHEMANAME_NATIVESDK".framework \
   -output ./../XCFramework/"$SCHEMANAME_NATIVESDK".xcframework

# Removed archive and output folder
rm -rf ./iphonesimulator
rm -rf ./iphoneos

 
# Copy OMSDK_Appnexus.xcframework from Viewability to XCFramework
cp -a "./sourcefiles/Viewability/OMSDK_Appnexus.xcframework" "../XCFramework" 


# Move to XCFramework folder
cd ..
cd XCFramework

# create zip with name AppNexusSDK.xcframework.zip which included   AppNexusSDK.xcframework OMSDK_Appnexus.xcframework and AppNexusNativeSDK.xcframework
zip -r ../AppNexusSDK.xcframework.zip *
cd ..

# Removed XCFramework  folder

rm -rf XCFramework

