#!/bin/bash
#
# Script to build the AppNexus SDK and various mediation adapters
#
OUTDIR=`pwd`/out
OD_DEVICE=`pwd`/out_device
OD_SIMULATOR=`pwd`/out_simulator
LOGDIR="$OUTDIR"/log
BUILDDIR="$OUTDIR"/build

BITCODE=true

#!/bin/bash
while [ ! $# -eq 0 ]
do
    case "$1" in
        --bitcode | -b)
            BITCODE=true
            ;;
	--no-bitcode | -nb)
	    BITCODE=false
	    ;;
    esac
    shift
done

BITCODEFLAG=""
if [ $BITCODE == true ]; then
    BITCODEFLAG="-fembed-bitcode"
    echo "Bitcode enabled"
fi

schemes=( ANSDK ANSDKGoogleAdMobAdapter ANSDKFacebookAdapter ANSDKMillennialMediaAdapter ANSDKMoPubAdapter ANSDKAmazonAdapter ANSDKInMobiAdapter ANSDKVdopiaAdapter ANSDKVungleAdapter ANSDKAdColonyAdapter ANSDKChartboostAdapter ANSDKYahooAdapter ANAdapterForGoogleAdMobSDK ANAdapterForMoPubSDK ANSDKSmartAdAdapter ANSDKAdMarvelAdapter ANSDKRubiconAdapter )

rm -fr "$OUTDIR" > /dev/null 2>&1
rm -fr "$OD_DEVICE" > /dev/null 2>&1
rm -fr "$OD_SIMULATOR" > /dev/null 2>&1
mkdir -p "$LOGDIR"

function buildDevice {
	echo "Building for device:" $1
	LOGFILE="$LOGDIR"/$1.log
	xcodebuild -project "ANSDK.xcodeproj" -scheme $1 -configuration "Release" -sdk "iphoneos" OTHER_CFLAGS="$BITCODEFLAG" CONFIGURATION_BUILD_DIR="$OUTDIR" SYMROOT="$BUILDDIR" OBJROOT="$BUILDDIR" > "$LOGFILE" 2>&1 || { echo "Error in build check log "$LOGFILE""; exit;}
	mkdir -p "$OUTDIR"/$1
	mv "$OUTDIR"/lib$1.a "$OUTDIR"/$1/lib$1.a
}

function buildSim {
	echo "Building for simulator:" $1
	LOGFILE="$LOGDIR"/$1.log
	xcodebuild -project "ANSDK.xcodeproj" -scheme $1 -configuration "Release" -sdk "iphonesimulator" OTHER_CFLAGS="$BITCODEFLAG" CONFIGURATION_BUILD_DIR="$OUTDIR" SYMROOT="$BUILDDIR" OBJROOT="$BUILDDIR" > "$LOGFILE" 2>&1 || { echo "Error in build check log "$LOGFILE""; exit;}
	mkdir -p "$OUTDIR"/$1
	mv "$OUTDIR"/lib$1.a "$OUTDIR"/$1/lib$1.a
}

### device

for i in ${schemes[@]}
do
	buildDevice $i
done

rm -rf "$OUTDIR"/Intermediates
rm -rf "$BUILDDIR"

mv "$OUTDIR" "$OD_DEVICE"

### simulator

mkdir -p "$LOGDIR"

for i in ${schemes[@]}
do
	buildSim $i
done

rm -rf "$OUTDIR"/Intermediates
rm -rf "$BUILDDIR"

mv "$OUTDIR" "$OD_SIMULATOR"

### combine
echo 'Combining architectures and copying header and resource files'

for i in ${schemes[@]}
do
	mkdir -p "$OUTDIR"/$i
	lipo -create "$OD_DEVICE"/$i/lib$i.a "$OD_SIMULATOR"/$i/lib$i.a  -output "$OUTDIR"/$i/lib$i.a
	rm -rf "$OD_DEVICE"/$i/lib$i.a
	cp -a "$OD_DEVICE"/$i "$OUTDIR"
done


rm -fr "$OD_DEVICE" > /dev/null 2>&1
rm -fr "$OD_SIMULATOR" > /dev/null 2>&1
rm -rf `pwd`/build

#####
# Package and Zip
#####

ANMEDDIR="$OUTDIR"/NetworksMediatedByAppNexusSDK

cd "$OUTDIR"
mkdir -p "$ANMEDDIR"

for i in ${schemes[@]}
do
    if [[ $i == ANSDK* ]] && [[ $i == *Adapter ]];
    then
	cp -a $i "$ANMEDDIR"
	rm -rf $i
	tmp=${i#ANSDK}
        className=${tmp%Adapter}
	mv "$ANMEDDIR"/$i "$ANMEDDIR"/$className
    fi
done

MEDANDIR="$OUTDIR"/NetworksMediatingAppNexusSDK

mkdir -p "$MEDANDIR"

for i in ${schemes[@]}
do
    if [[ $i == ANAdapterFor* ]];
    then
        cp -a $i "$MEDANDIR"
        rm -rf $i
        tmp=${i#ANAdapterFor}
	className=${tmp%SDK}
	mv "$MEDANDIR"/$i "$MEDANDIR"/$className
    fi
done

mv "$OUTDIR"/"ANSDK" "$OUTDIR"/"AppNexusSDK"

touch README.txt
echo -e "
The AppNexus Mobile Advertising SDK for iOS
===========================================

The AppNexusSDK folder contains the AppNexus mobile advertising SDK. Documentation is available on our wiki (https://wiki.appnexus.com/display/sdk/Mobile+SDKs).

The NetworksMediatedByAppNexusSDK folder contains adapters which allow the AppNexus SDK to serve mediated ads from third-party SDKs. For each network you would like the SDK to mediate, include the network's folder, along with the corresponding third-party SDK, in your project.

The NetworksMediatingAppNexusSDK folder contains adapters which allow third-party SDKs to mediate AppNexus. Include an adapter in your project for the SDK which should call AppNexus as part of its mediation waterfall.

Please note that mediation requires external setup as well. Documentation is available on our wiki (https://wiki.appnexus.com/display/sdk/Mediate+with+iOS).

For any questions directly pertaining to the SDK, please visit our Google group (https://groups.google.com/forum/#!forum/appnexussdk). For other inquiries, please reach out to your AppNexus representative.

All The Best,

Your AppNexus Team

" >> README.txt

function packageSDK {
    if [[ $i == ANSDK* ]] && [[ $i == *Adapter ]];
    then
	tmp=${i#ANSDK}
	className=${tmp%Adapter}
	SDKDIR="$OUTDIR"/../../mediation/mediatedviews/${className}/${className}SDK
	if [ -d "$SDKDIR" ];
	then
	    echo "Packaging ${className} SDK"
	    cp -r "$SDKDIR" "$2"
	else
	    echo "Warning: ${className} SDK not found"
	fi
    fi
}

external="$OUTDIR"/ExternalLibraries
mkdir -p "$external"

for i in ${schemes[@]}
do
    packageSDK $i "$external"
done
