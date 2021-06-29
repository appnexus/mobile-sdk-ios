# Output directory name
OUTDIR=$1+"Framework"
# Scheme name AppNexusSDK OR AppNexusNativeSDK
SCHEMENAME=$1
# for iPhones
OD_DEVICE="iphoneos"
# for simulator
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

# Zip XCFramework
#zip -r "$OUTDIR" ../XCFramework

# Removed archive and output folder
rm -rf ./iphonesimulator
rm -rf ./iphoneos
#rm -rf ./../XCFramework
