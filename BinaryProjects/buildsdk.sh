#!/bin/bash
#
# Simple script to built the AppNexus Advertising SDK binary packages
#
OUTDIR=`pwd`/out
OUTDIR_DEVICE=`pwd`/out_device
OUTDIR_SIMULATOR=`pwd`/out_simulator
LOGDIR=$OUTDIR/log
BUILDDIR=$OUTDIR/build

projects=( ANSDK ANSDKGoogleAdMobAdapter ANSDKFacebookAdapter ANSDKiAdAdapter ANSDKMillennialMediaAdapter ANSDKMoPubAdapter ANAdapterForGoogleAdMobSDK ANAdapterForMoPubSDK )

rm -fr $OUTDIR > /dev/null 2>&1
rm -fr $OUTDIR_DEVICE > /dev/null 2>&1
rm -fr $OUTDIR_SIMULATOR > /dev/null 2>&1
mkdir -p $LOGDIR

function buildDevice {
	echo "Building for device:" $1
	LOGFILE=$LOGDIR/$1.log
	xcodebuild -project $1.xcodeproj/ -scheme $1 -configuration 'Release' -sdk iphoneos7.1 CONFIGURATION_BUILD_DIR=$OUTDIR SYMROOT=$BUILDDIR OBJROOT=$BUILDDIR > $LOGFILE 2>&1 || { echo "Error in build check log $LOGFILE"; exit;}
	mkdir -p $OUTDIR/$1
	mv $OUTDIR/lib$1.a $OUTDIR/$1/lib$1.a
}

function buildSim {
	echo "Building for simulator:" $1
	LOGFILE=$LOGDIR/$1.log
	xcodebuild -project $1.xcodeproj/ -scheme $1 -configuration 'Release' -sdk "iphonesimulator" CONFIGURATION_BUILD_DIR=$OUTDIR SYMROOT=$BUILDDIR OBJROOT=$BUILDDIR > $LOGFILE 2>&1 || { echo "Error in build check log $LOGFILE"; exit;}
	mkdir -p $OUTDIR/$1
	mv $OUTDIR/lib$1.a $OUTDIR/$1/lib$1.a
}

### device

for i in ${projects[@]} 
do
	buildDevice $i
done

rm -rf $OUTDIR/Intermediates
rm -rf $BUILDDIR

mv $OUTDIR $OUTDIR_DEVICE

### simulator

mkdir -p $LOGDIR

for i in ${projects[@]} 
do
	buildSim $i
done

rm -rf $OUTDIR/Intermediates
rm -rf $BUILDDIR

mv $OUTDIR $OUTDIR_SIMULATOR

### combine
echo 'Combining architectures and copying header and resource files'

for i in ${projects[@]} 
do
	mkdir -p $OUTDIR/$i
	lipo -create $OUTDIR_DEVICE/$i/lib$i.a $OUTDIR_SIMULATOR/$i/lib$i.a  -output $OUTDIR/$i/lib$i.a
	rm -rf $OUTDIR_DEVICE/$i/lib$i.a
	cp -a $OUTDIR_DEVICE/$i $OUTDIR
done


rm -fr $OUTDIR_DEVICE > /dev/null 2>&1
rm -fr $OUTDIR_SIMULATOR > /dev/null 2>&1
rm -rf `pwd`/build

#####
# Package and Zip
#####

MEDDIR=$OUTDIR/ANMediationAdapters

cd $OUTDIR
mkdir -p $MEDDIR
cp ANSDK*Adapter/libANSDK*Adapter.a $MEDDIR
rm -rf ANSDK*Adapter

zip -r ANSDK.zip ANSDK ANMediationAdapters
zip -r ANAdapterForGoogleAdMobSDK.zip ANAdapterForGoogleAdMobSDK
zip -r ANAdapterForMoPubSDK.zip ANAdapterForMoPubSDK
