OUTDIR=`pwd`/universal
OD_DEVICE=`pwd`/iphoneos
OD_SIMULATOR=`pwd`/iphonesimulator
LOGDIR="$OUTDIR"/log
BUILDDIR="$OUTDIR"/build
SCHEMENAME="AppNexusSDK"

rm -fr "$OUTDIR" > /dev/null 2>&1
rm -fr "$OD_DEVICE" > /dev/null 2>&1
rm -fr "$OD_SIMULATOR" > /dev/null 2>&1

BITCODEFLAG="-fembed-bitcode"
echo "Bitcode enabled"

function buildDevice {
    echo "Building framework for device:" $1
    LOGFILE="$LOGDIR"/$1.log
    xcodebuild -project "AppNexusSDK.xcodeproj" -scheme $1 -configuration "Release" -sdk "iphoneos" BITCODE_GENERATION_MODE="bitcode" OTHER_CFLAGS="$BITCODEFLAG" CONFIGURATION_BUILD_DIR="$OUTDIR" SYMROOT="$BUILDDIR" OBJROOT="$BUILDDIR" > "$LOGFILE" 2>&1 || { echo "Error in build check log "$LOGFILE""; exit;}
    mkdir -p "$OUTDIR"/$1
    mv "$OUTDIR"/$1.framework "$OUTDIR"/$1/$1.framework
}

function buildSim {
    echo "Building framework for simulator:" $1
    LOGFILE="$LOGDIR"/$1.log
    xcodebuild -project "AppNexusSDK.xcodeproj" -scheme $1 -configuration "Release" -sdk "iphonesimulator" BITCODE_GENERATION_MODE="bitcode" OTHER_CFLAGS="$BITCODEFLAG" CONFIGURATION_BUILD_DIR="$OUTDIR" SYMROOT="$BUILDDIR" OBJROOT="$BUILDDIR" > "$LOGFILE" 2>&1 || { echo "Error in build check log "$LOGFILE""; exit;}
    mkdir -p "$OUTDIR"/$1
    mv "$OUTDIR"/$1.framework "$OUTDIR"/$1/$1.framework
}

### device
mkdir -p "$LOGDIR"
buildDevice $SCHEMENAME
rm -rf "$OUTDIR"/Intermediates
rm -rf "$BUILDDIR"
rm -rf "$LOGDIR"
rm -rf "$OUTDIR"/"$SCHEMENAME.framework.dSYM"
rm -rf "$OUTDIR"/"AppNexusSDKResources.bundle"

mv "$OUTDIR" "$OD_DEVICE"

### simulator

mkdir -p "$LOGDIR"
buildSim $SCHEMENAME
rm -rf "$OUTDIR"/Intermediates
rm -rf "$BUILDDIR"
rm -rf "$LOGDIR"
rm -rf "$OUTDIR"/"$SCHEMENAME.framework.dSYM"
rm -rf "$OUTDIR"/"AppNexusSDKResources.bundle"
mv "$OUTDIR" "$OD_SIMULATOR"

### combine
echo 'Combining framework architectures'

mkdir -p "$OUTDIR"/$SCHEMENAME
cp -a "$OD_DEVICE"/$SCHEMENAME/$SCHEMENAME.framework "$OUTDIR"/$SCHEMENAME
lipo -create "$OD_DEVICE"/$SCHEMENAME/$SCHEMENAME.framework/$SCHEMENAME "$OD_SIMULATOR"/$SCHEMENAME/$SCHEMENAME.framework/$SCHEMENAME  -output "$OUTDIR"/$SCHEMENAME/$SCHEMENAME.framework/$SCHEMENAME
rm -rf `pwd`/build

zip -r AppNexusSDKFramework.zip iphonesimulator universal iphoneos
rm -rf "$OUTDIR"
rm -rf "$OD_DEVICE"
rm -rf "$OD_SIMULATOR"

