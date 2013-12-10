#!/bin/bash
#
# Simple script to built the AppNexus Advertising SDK binary packages
#
OUTDIR=`pwd`/out
LOGDIR=$OUTDIR/log
BUILDDIR=$OUTDIR/build
rm -fr $OUTDIR > /dev/null 2>&1
mkdir -p $LOGDIR


echo "Started building of AN SDK"
LOGFILE=$LOGDIR/ANSDK.log
xcodebuild -project 'ANSDK.xcodeproj/' -scheme 'ANSDK' -configuration 'Release' -sdk iphoneos7.0 CONFIGURATION_BUILD_DIR='out' SYMROOT=$BUILDDIR OBJROOT=$BUILDDIR > $LOGFILE 2>&1 || { echo "Error in build check log $LOGFILE"; exit;}
mv $OUTDIR/libANSDK.a $OUTDIR/ANSDK/libANSDK.a

echo "Started building of Full AN SDK"
LOGFILE=$LOGDIR/ANSDKFull.log
xcodebuild -project 'ANSDKFull.xcodeproj/' -scheme 'ANSDKFull' -configuration 'Release' -sdk iphoneos7.0 CONFIGURATION_BUILD_DIR='out' > $LOGFILE 2>&1 || { echo "Error in build check log $LOGFILE"; exit;}
mv $OUTDIR/libANSDKFull.a $OUTDIR/ANSDKFull/libANSDKFull.a

echo "Started building of Full AN SDK with Mopub Adaptor"
LOGFILE=$LOGDIR/ANSDKFullMopub.log
xcodebuild -project 'ANSDKMoPub.xcodeproj/' -scheme 'ANSDKMoPub' -configuration 'Release' -sdk iphoneos7.0 CONFIGURATION_BUILD_DIR='out' > $LOGFILE 2>&1 || { echo "Error in build check log $LOGFILE"; exit;}
mv $OUTDIR/libANSDKMoPub.a $OUTDIR/ANSDKMoPub/libANSDKMoPub.a

echo "Started building of Full AN SDK with Admob Adaptor"
LOGFILE=$LOGDIR/ANSDKFullAdmob.log
xcodebuild -project 'ANSDKAdMob.xcodeproj/' -scheme 'ANSDKAdMob' -configuration 'Release' -sdk iphoneos7.0 CONFIGURATION_BUILD_DIR='out' > $LOGFILE 2>&1 || { echo "Error in build check log $LOGFILE"; exit;}
mv $OUTDIR/libANSDKAdMob.a $OUTDIR/ANSDKAdMob/libANSDKAdMob.a

rm -rf $OUTDIR/Intermediates
rm -rf $BUILDDIR
