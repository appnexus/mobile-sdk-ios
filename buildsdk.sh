#!/bin/bash
#
# Simple script to built the AppNexus Advertising SDK binary packages
#
OUTDIR=`pwd`/out
OUTDIR_DEVICE=`pwd`/out_device
OUTDIR_SIMULATOR=`pwd`/out_simulator
LOGDIR=$OUTDIR/log
BUILDDIR=$OUTDIR/build

rm -fr $OUTDIR > /dev/null 2>&1
rm -fr $OUTDIR_DEVICE > /dev/null 2>&1
rm -fr $OUTDIR_SIMULATOR > /dev/null 2>&1
mkdir -p $LOGDIR

### device

echo "Started building of AN SDK"
LOGFILE=$LOGDIR/ANSDK.log
xcodebuild -project 'ANSDK.xcodeproj/' -scheme 'ANSDK' -configuration 'Release' -sdk iphoneos7.1 CONFIGURATION_BUILD_DIR=$OUTDIR SYMROOT=$BUILDDIR OBJROOT=$BUILDDIR > $LOGFILE 2>&1 || { echo "Error in build check log $LOGFILE"; exit;}
mv $OUTDIR/libANSDK.a $OUTDIR/ANSDK/libANSDK.a

echo "Started building of Full AN SDK"
LOGFILE=$LOGDIR/ANSDKFull.log
xcodebuild -project 'ANSDKFull.xcodeproj/' -scheme 'ANSDKFull' -configuration 'Release' -sdk iphoneos7.1 CONFIGURATION_BUILD_DIR=$OUTDIR > $LOGFILE 2>&1 || { echo "Error in build check log $LOGFILE"; exit;}
mv $OUTDIR/libANSDKFull.a $OUTDIR/ANSDKFull/libANSDKFull.a

echo "Started building of Full AN SDK with Mopub Adaptor"
LOGFILE=$LOGDIR/ANSDKFullMopub.log
xcodebuild -project 'ANSDKMoPub.xcodeproj/' -scheme 'ANSDKMoPub' -configuration 'Release' -sdk iphoneos7.1 CONFIGURATION_BUILD_DIR=$OUTDIR > $LOGFILE 2>&1 || { echo "Error in build check log $LOGFILE"; exit;}
mv $OUTDIR/libANSDKMoPub.a $OUTDIR/ANSDKMoPub/libANSDKMoPub.a

echo "Started building of Full AN SDK with Admob Adaptor"
LOGFILE=$LOGDIR/ANSDKFullAdmob.log
xcodebuild -project 'ANSDKAdMob.xcodeproj/' -scheme 'ANSDKAdMob' -configuration 'Release' -sdk iphoneos7.1 CONFIGURATION_BUILD_DIR=$OUTDIR > $LOGFILE 2>&1 || { echo "Error in build check log $LOGFILE"; exit;}
mv $OUTDIR/libANSDKAdMob.a $OUTDIR/ANSDKAdMob/libANSDKAdMob.a

rm -rf $OUTDIR/Intermediates
rm -rf $BUILDDIR

mv $OUTDIR $OUTDIR_DEVICE

### simulator

mkdir -p $LOGDIR

echo "Started building of AN SDK"
LOGFILE=$LOGDIR/ANSDK.log
xcodebuild -project 'ANSDK.xcodeproj/' -scheme 'ANSDK' -configuration 'Release' -sdk "iphonesimulator" CONFIGURATION_BUILD_DIR=$OUTDIR SYMROOT=$BUILDDIR OBJROOT=$BUILDDIR > $LOGFILE 2>&1 || { echo "Error in build check log $LOGFILE"; exit;}
mv $OUTDIR/libANSDK.a $OUTDIR/ANSDK/libANSDK.a

echo "Started building of Full AN SDK"
LOGFILE=$LOGDIR/ANSDKFull.log
xcodebuild -project 'ANSDKFull.xcodeproj/' -scheme 'ANSDKFull' -configuration 'Release' -sdk "iphonesimulator" CONFIGURATION_BUILD_DIR=$OUTDIR > $LOGFILE 2>&1 || { echo "Error in build check log $LOGFILE"; exit;}
mv $OUTDIR/libANSDKFull.a $OUTDIR/ANSDKFull/libANSDKFull.a

echo "Started building of Full AN SDK with Mopub Adaptor"
LOGFILE=$LOGDIR/ANSDKFullMopub.log
xcodebuild -project 'ANSDKMoPub.xcodeproj/' -scheme 'ANSDKMoPub' -configuration 'Release' -sdk "iphonesimulator" CONFIGURATION_BUILD_DIR=$OUTDIR > $LOGFILE 2>&1 || { echo "Error in build check log $LOGFILE"; exit;}
mv $OUTDIR/libANSDKMoPub.a $OUTDIR/ANSDKMoPub/libANSDKMoPub.a

echo "Started building of Full AN SDK with Admob Adaptor"
LOGFILE=$LOGDIR/ANSDKFullAdmob.log
xcodebuild -project 'ANSDKAdMob.xcodeproj/' -scheme 'ANSDKAdMob' -configuration 'Release' -sdk "iphonesimulator" CONFIGURATION_BUILD_DIR=$OUTDIR > $LOGFILE 2>&1 || { echo "Error in build check log $LOGFILE"; exit;}
mv $OUTDIR/libANSDKAdMob.a $OUTDIR/ANSDKAdMob/libANSDKAdMob.a

rm -rf $OUTDIR/Intermediates
rm -rf $BUILDDIR

mv $OUTDIR $OUTDIR_SIMULATOR

### combine

mkdir -p $OUTDIR/ANSDK
mkdir -p $OUTDIR/ANSDKFull
mkdir -p $OUTDIR/ANSDKAdMob
mkdir -p $OUTDIR/ANSDKMoPub

echo "Combining architectures into one"
lipo -create $OUTDIR_DEVICE/ANSDK/libANSDK.a $OUTDIR_SIMULATOR/ANSDK/libANSDK.a  -output $OUTDIR/ANSDK/libANSDK.a
lipo -create $OUTDIR_DEVICE/ANSDKFull/libANSDKFull.a $OUTDIR_SIMULATOR/ANSDKFull/libANSDKFull.a  -output $OUTDIR/ANSDKFull/libANSDKFull.a
lipo -create $OUTDIR_DEVICE/ANSDKAdMob/libANSDKAdMob.a $OUTDIR_SIMULATOR/ANSDKAdMob/libANSDKAdMob.a  -output $OUTDIR/ANSDKAdMob/libANSDKAdMob.a
lipo -create $OUTDIR_DEVICE/ANSDKMoPub/libANSDKMoPub.a $OUTDIR_SIMULATOR/ANSDKMoPub/libANSDKMoPub.a  -output $OUTDIR/ANSDKMoPub/libANSDKMoPub.a

rm -rf $OUTDIR_DEVICE/ANSDK/libANSDK.a
rm -rf $OUTDIR_DEVICE/ANSDKFull/libANSDKFull.a
rm -rf $OUTDIR_DEVICE/ANSDKAdMob/libANSDKAdMob.a
rm -rf $OUTDIR_DEVICE/ANSDKMoPub/libANSDKMoPub.a

echo "Copy header and resource files"
cp -r $OUTDIR_DEVICE/ANSDK $OUTDIR
cp -r $OUTDIR_DEVICE/ANSDKFull $OUTDIR
cp -r $OUTDIR_DEVICE/ANSDKAdMob $OUTDIR
cp -r $OUTDIR_DEVICE/ANSDKMoPub $OUTDIR

rm -fr $OUTDIR_DEVICE > /dev/null 2>&1
rm -fr $OUTDIR_SIMULATOR > /dev/null 2>&1

