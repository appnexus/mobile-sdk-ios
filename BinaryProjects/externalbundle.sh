##########
# RUN `buildsdk.sh` FIRST!
##########

#####
# This is a build script to build the external bundle
# Bundle Includes:
#
# AN SDK
#
# AN Mediation Adapters for: 
# # GoogleAdMob
# # iAd
# # MillennialMedia
#
# External SDKs for:
# # GoogleAdMob SDK
# # MillennialMedia SDK
#
# Not Included:
# # Facebook Adapter + SDK
# # MoPub Adapter + SDK
# # iAd.framework
# 
#####

ROOTDIR=`pwd`/..
OUTDIR=`pwd`/out
MEDDIR=$OUTDIR/ANMediationAdapters
EXTDIR=$ROOTDIR/mediation/mediatedviews
GOOGLESDK=$EXTDIR/GoogleAdMob/GoogleAdMobSDK
MMSDK=$EXTDIR/MillennialMedia/MillennialMediaSDK

BUNDIR=$OUTDIR/ANSDKExternalBundle
BUNEXTDIR=$BUNDIR/ANExternalNetworks
BUNGOOGLEDIR=$BUNEXTDIR/GoogleAdMob
BUNMMDIR=$BUNEXTDIR/MillennialMedia

#cleanup
rm -rf $BUNDIR

mkdir -p $BUNGOOGLEDIR
mkdir -p $BUNMMDIR

# Include Google and MM SDKs.
cp $GOOGLESDK/libGoogleAdMobAds.a $BUNGOOGLEDIR
cp $GOOGLESDK/README.txt $BUNGOOGLEDIR

cp -r $MMSDK/MillennialMedia.framework $BUNMMDIR
cp $MMSDK/LICENSE.txt $BUNMMDIR

# Grab all adapters
cp -r $MEDDIR $BUNDIR

# Exclude FB + MP
rm -rf $BUNDIR/ANMediationAdapters/libANSDKFacebookAdapter.a
rm -rf $BUNDIR/ANMediationAdapters/libANSDKMoPubAdapter.a

# Base AN SDK
cp -r $OUTDIR/ANSDK $BUNDIR

# Zip it up
cd $OUTDIR
zip -r ANSDKExternalBundle.zip ANSDKExternalBundle


