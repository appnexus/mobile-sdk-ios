OUTDIR=`pwd`/out
OUTDIR_DEVICE=`pwd`/out_device
OUTDIR_SIMULATOR=`pwd`/out_simulator
LOGDIR=$OUTDIR/log
BUILDDIR=$OUTDIR/build
SCHEMENAME="AppNexusSDK"

rm -fr $OUTDIR > /dev/null 2>&1
rm -fr $OUTDIR_DEVICE > /dev/null 2>&1
rm -fr $OUTDIR_SIMULATOR > /dev/null 2>&1

function buildDevice {
    echo "Building framework for device:" $1
    LOGFILE=$LOGDIR/$1.log
    xcodebuild -project "ANSDK.xcodeproj" -scheme $1 -configuration "Release" -sdk "iphoneos" CONFIGURATION_BUILD_DIR=$OUTDIR SYMROOT=$BUILDDIR OBJROOT=$BUILDDIR > $LOGFILE 2>&1 || { echo "Error in build check log $LOGFILE"; exit;}
    mkdir -p $OUTDIR/$1
    mv $OUTDIR/$1.framework $OUTDIR/$1/$1.framework
}

function buildSim {
    echo "Building framework for simulator:" $1
    LOGFILE=$LOGDIR/$1.log
    xcodebuild -project "ANSDK.xcodeproj" -scheme $1 -configuration "Release" -sdk "iphonesimulator" CONFIGURATION_BUILD_DIR=$OUTDIR SYMROOT=$BUILDDIR OBJROOT=$BUILDDIR > $LOGFILE 2>&1 || { echo "Error in build check log $LOGFILE"; exit;}
    mkdir -p $OUTDIR/$1
    mv $OUTDIR/$1.framework $OUTDIR/$1/$1.framework
}

### device
mkdir -p $LOGDIR
buildDevice $SCHEMENAME
rm -rf $OUTDIR/Intermediates
rm -rf $BUILDDIR
mv $OUTDIR $OUTDIR_DEVICE

### simulator

mkdir -p $LOGDIR
buildSim $SCHEMENAME
rm -rf $OUTDIR/Intermediates
rm -rf $BUILDDIR
mv $OUTDIR $OUTDIR_SIMULATOR

### combine
echo 'Combining framework architectures'

mkdir -p $OUTDIR/$SCHEMENAME
cp -a $OUTDIR_DEVICE/$SCHEMENAME/$SCHEMENAME.framework $OUTDIR/$SCHEMENAME
lipo -create $OUTDIR_DEVICE/$SCHEMENAME/$SCHEMENAME.framework/$SCHEMENAME $OUTDIR_SIMULATOR/$SCHEMENAME/$SCHEMENAME.framework/$SCHEMENAME  -output $OUTDIR/$SCHEMENAME/$SCHEMENAME.framework/$SCHEMENAME
rm -rf $OUTDIR_DEVICE/$SCHEMENAME/$SCHEMENAME.framework

rm -fr $OUTDIR_DEVICE > /dev/null 2>&1
rm -fr $OUTDIR_SIMULATOR > /dev/null 2>&1
rm -rf `pwd`/build
