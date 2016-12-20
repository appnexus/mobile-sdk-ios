OUTDIR=`pwd`/out
OD_DEVICE=`pwd`/out_device
OD_SIMULATOR=`pwd`/out_simulator
LOGDIR="$OUTDIR"/log
BUILDDIR="$OUTDIR"/build
SCHEMENAME="AppNexusSDK"

rm -fr "$OUTDIR" > /dev/null 2>&1
rm -fr "$OD_DEVICE" > /dev/null 2>&1
rm -fr "$OD_SIMULATOR" > /dev/null 2>&1

function buildDevice {
    echo "Building framework for device:" $1
    LOGFILE="$LOGDIR"/$1.log
    xcodebuild -project "ANSDK.xcodeproj" -scheme $1 -configuration "Release" -sdk "iphoneos" CONFIGURATION_BUILD_DIR="$OUTDIR" SYMROOT="$BUILDDIR" OBJROOT="$BUILDDIR" > "$LOGFILE" 2>&1 || { echo "Error in build check log "$LOGFILE""; exit;}
    mkdir -p "$OUTDIR"/$1
    mv "$OUTDIR"/$1.framework "$OUTDIR"/$1/$1.framework
}

function buildSim {
    echo "Building framework for simulator:" $1
    LOGFILE="$LOGDIR"/$1.log
    xcodebuild -project "ANSDK.xcodeproj" -scheme $1 -configuration "Release" -sdk "iphonesimulator" CONFIGURATION_BUILD_DIR="$OUTDIR" SYMROOT="$BUILDDIR" OBJROOT="$BUILDDIR" > "$LOGFILE" 2>&1 || { echo "Error in build check log "$LOGFILE""; exit;}
    mkdir -p "$OUTDIR"/$1
    mv "$OUTDIR"/$1.framework "$OUTDIR"/$1/$1.framework
}

### device
mkdir -p "$LOGDIR"
buildDevice $SCHEMENAME
rm -rf "$OUTDIR"/Intermediates
rm -rf "$BUILDDIR"
mv "$OUTDIR" "$OD_DEVICE"

### simulator

mkdir -p "$LOGDIR"
buildSim $SCHEMENAME
rm -rf "$OUTDIR"/Intermediates
rm -rf "$BUILDDIR"
mv "$OUTDIR" "$OD_SIMULATOR"

### combine
echo 'Combining framework architectures'

mkdir -p "$OUTDIR"/$SCHEMENAME
cp -a "$OD_DEVICE"/$SCHEMENAME/$SCHEMENAME.framework "$OUTDIR"/$SCHEMENAME
lipo -create "$OD_DEVICE"/$SCHEMENAME/$SCHEMENAME.framework/$SCHEMENAME "$OD_SIMULATOR"/$SCHEMENAME/$SCHEMENAME.framework/$SCHEMENAME  -output "$OUTDIR"/$SCHEMENAME/$SCHEMENAME.framework/$SCHEMENAME
rm -rf "$OD_DEVICE"/$SCHEMENAME/$SCHEMENAME.framework

rm -fr "$OD_DEVICE" > /dev/null 2>&1
rm -fr "$OD_SIMULATOR" > /dev/null 2>&1
rm -rf `pwd`/build
