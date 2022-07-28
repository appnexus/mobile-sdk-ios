/*   Copyright 2020 APPNEXUS INC
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

/*
 About Constant
 Delcear the Constant for Application and Test target
 */


/**
 @param MockTestcase : 1 to enable mocking and 0 to disbable mocking
 */
#define MockTestcase 1
/**
 @param ForceCreative : 1 to enable force creative and 0 to disbable force creative
 */
#define ForceCreative 1
// To use live placement for testing set MockTestcase 0  & ForceCreative 0

/**
 Set Placaement Id for different type of Ad
 */
#define BannerPlacementId @"19213468"
#define NativePlacementId @"19213468"
#define BannerNativeRendererPlacementId @"20331545"
#define VideoPlacementId @"19213468"
#define InterstitialPlacementId @"17058950"
#define MARPlacementId @"17058950"



/**
 Set Creative Id for different type of Ad
 */
#define BannerForceCreativeId 156075267
#define NativeForceCreativeId 142877136
#define VideoForceCreativeId 162035356
#define InterstitialForceCreativeId 156075267

/**
 Constant used to run testcase and track URL for Click and Impression Tracker
 */
#define BannerImpressionClickTrackerTest @"BannerImpressionClickTrackerTest"
#define BannerNativeImpressionClickTrackerTest @"BannerNativeImpressionClickTrackerTest"
#define BannerImpressionClickTrackerTestWithCallback @"BannerImpressionClickTrackerTestWithCallback"
#define BannerNativeRendererImpressionClickTrackerTest @"BannerNativeRendererImpressionClickTrackerTest"
#define BannerVideoImpressionClickTrackerTest @"BannerVideoImpressionClickTrackerTest"
#define InterstitialImpressionClickTrackerTest @"InterstitialImpressionClickTrackerTest"
#define InterstitialImpressionClickTrackerTestWithCallback @"InterstitialImpressionClickTrackerTestWithCallback"
#define VideoImpressionClickTrackerTest @"VideoImpressionClickTrackerTest"
#define NativeImpressionClickTrackerTest @"NativeImpressionClickTrackerTest"
#define NativeMultiClickTrackerTest @"NativeMultiClickTrackerTest"
#define NativeMultiImpressionTrackerTest @"NativeMultiImpressionTrackerTest"
#define MARBannerImpressionClickTrackerTest @"MARBannerImpressionClickTrackerTest"
#define MARNativeImpressionClickTrackerTest @"MARNativeImpressionClickTrackerTest"
#define MARBannerNativeRendererImpressionClickTrackerTest @"MARBannerNativeRendererImpressionClickTrackerTest"
#define BannerImpression1PxTrackerTest @"BannerImpression1PxTrackerTest"
#define NativeImpression1PxTrackerTest @"NativeImpression1PxTrackerTest"

/**
 Constant used to run testcase and track URL for OMID Tracker
 */
#define BannerViewabilityTrackerTest @"BannerViewabilityTrackerTest"
#define BannerNativeViewabilityTrackerTest @"BannerNativeViewabilityTrackerTest"
#define BannerNativeRendererViewabilityTrackerTest @"BannerNativeRendererViewabilityTrackerTest"
#define BannerVideoViewabilityTrackerTest @"BannerVideoViewabilityTrackerTest"
#define InterstitialViewabilityTrackerTest @"InterstitialViewabilityTrackerTest"
#define VideoViewabilityTrackerTest @"VideoViewabilityTrackerTest"
#define NativeViewabilityTrackerTest @"NativeViewabilityTrackerTest"

#define NativeAdExpiry @"NativeAdExpiry"
#define NativeAdExpiry_270 @"NativeAdExpiry_270"
#define NativeAdExpiry_310 @"NativeAdExpiry_310"

#define MARBannerViewabilityTrackerTest @"MARBannerViewabilityTrackerTest"
#define MARNativeViewabilityTrackerTest @"MARNativeViewabilityTrackerTest"
#define MARBannerNativeRendererViewabilityTrackerTest @"MARBannerNativeRendererViewabilityTrackerTest"

/**
 List of possible URL that can be fired during click events
 */
#define clickTrackerURLRTB [NSArray arrayWithObjects: @"https://sin1-mobile.adnxs.com/click?",@"http://nym1-ib.adnxs.com/click?",@"https://nym1-mobile.adnxs.com/click?",@"https://sin3-ib.adnxs.com/click?",@"https://sin3-ib.adnxs.com/vevent?an_audit=0",@"https://wiki.xandr.com",@"https://www.xandr.com/",nil]
/**
 List of possible URL that can be fired during impression events
 */
#define impressionTrackerURLRTB  [NSArray arrayWithObjects: @"https://sin1-mobile.adnxs.com/it?",@"http://nym1-ib.adnxs.com/it?",@"https://nym1-mobile.adnxs.com/it?",@"https://sin3-ib.adnxs.com/it?",@"https://nym1-ib.adnxs.com/vevent?an_audit=0",@"https://nym1-ib.adnxs.com/it?an_audit=0",@"https://nym2-tr.adnxs.com/it",nil]

/**
 Test case will wait for 25 Second  for Click Tracker
 */
#define ClickTrackerTimeout 25
/**
 Test case will wait for 25 Second  for Impression Tracker
 */
#define ImpressionTrackerTimeout 25

