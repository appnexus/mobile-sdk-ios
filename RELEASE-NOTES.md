## 7.2
### Improvements/Bug Fixes
+ MS-4200 : Support IAB Europe Transparency & Consent Framework v2.0
+ MS-4267 : All network calls will be made only using secure endpoint


## 7.1
### New Feature
+ MS-3956  Added ANAdResponseInfo to return associated data with Ad response 

### Mediation partner upgrade
+ Google AdMob SDK v7.55.0

### Improvements/Bug Fixes
+ MS-3882 Added option to include "publisher_id" in Ad request
+ MS-3896 Fixed bug on Interstitial Video Ad close feature
+ MS-4166 Fixed VideoAd OMID session tracker firing bug



## 7.0

### New Feature
+ MS-3885 Added support for Multi Ad Request (MAR) (https://wiki.xandr.com/display/sdk/Single+Request+Mode+for+iOS

### Mediation partner upgrade
+ Smart Server SDK v7.3.0

### Improvements/Bug Fixes
+ MS-4122 - Fixed potential memory leak issue caused by improper deallocation of InstreamVideoAd object
+ MS-4094 - Code clean up to fix issue with OMID SDK video implementation


## 6.2

### New Features
+ MS-4097 California Consumer Privacy Act (CCPA) Support (https://wiki.xandr.com/display/sdk/SDK+Privacy+for+iOS)

### Bug Fixes
+ MS-4124: Special characters not rendering over native assembly 
+ MS-4084: VideoAd Object not getting deallocated
+ MS-4095: Updated OMID partner name


## 6.1.2

### Improvements/Bug Fixes
+ MS-4092: fix for SKStoreProductViewController crash on iOS 13


## 6.1.1

### New Features
+ MS-3923: Added new API to get SDK version

### Improvements/Bug Fixes
+ MS-4091: Improved DFP second price option


## 6.1

### New Features
+ MS-3983: Added new API to Pause/Resume(https://wiki.xandr.com/display/sdk/Show+an+Instream+Video+Ads+on+iOS) VideoAd
+ MS-4057: Official release for iOS 13 support 

### Mediation partner upgrades
+ Smart Server SDK v7.2
+ FacebookAd SDK v5.5.1(has breaking changes, please look at Mediation Docs(https://wiki.xandr.com/display/sdk/Mediate+with+iOS) for updated integration instruction)
+ Google AdMob SDK v7.50

### Improvements/Bug Fixes
+ MS-3915,MS-3916: Improved Banner Ad performance 
+ MS-3948: Removed AppNexusSDKResources.Bundle
+ MS-3951: Fixed open measurement geometry change events for VideoAd
+ MS-3976: Fixed escape character breaking VideoAd load
+ MS-3987: Upgraded to OMSDK v1.2.19
+ MS-4004: Fixed VideoAd's pause issue when application state changes
+ MS-4023: Removed usage of UIWebView
+ MS-4036: Fixed interstitial crash on orientation change if orientation not supported by host application (Github #47)

## 6.0

At Xandr we listen to our users' feedback to help us develop the products that provide the best solutions for their needs. Based on that feedback, we are proud to announce the release of v6.0, a major upgrade to our iOS Mobile SDK.

### BREAKING CHANGES
**Some changes made in v6.0 are breaking and may require existing users who wish to upgrade from previous versions to follow our [migration guide.](https://wiki.appnexus.com/display/sdk/iOS+v6.0+SDK+Migration+and+Integration#iOSv6.0SDKMigrationandIntegration-migrate-to-6.)**

### New Features
#### Change to the directory structure. Notable changes include:
- BinaryProjects/ANSDK.xcodeproject has been renamed and moved to sdk/AppNexusSDK.xcodeproject.
- Mediation Adapter targets have been removed from AppNexusSDK.xcodeproject.
- ANSDK target has been removed from AppNexusSDK.xcodeproject.

#### Mediation adapters are now available only via our source or CocoaPods.
This will enable publishers to select the mediation networks they need for their inventory strategies

#### Third party mediation network libraries have been removed from code. Publishers integrating mediation via source will need to include the libraries themselves.
A list of supported versions of [third-party mediation networks](https://wiki.appnexus.com/display/sdk/Mediate+with+iOS+SDK+v6.0) is available in our public documentation

### Upgrades
#### Mediation partner upgrades
- Mopub SDK v5.8.0
- InMobi SDK v7.3.1
- Google AdMob SDK v7.48.0
- Smart Server SDK v7.1.1

**Warning:**
If you are currently using a static library version of AppNexus SDK(libANSDK.a) or a mediation adapter please follow our [migration guide](https://wiki.appnexus.com/display/sdk/iOS+v6.0+SDK+Migration+and+Integration#iOSv6.0SDKMigrationandIntegration-migrate-to-6.0).


## 6.0-Beta

**Note: This is a beta release of the AppNexus SDK, and will be open for feedback/comments for at least the next 14 days**

### New Features

+ SDK-Lite(6.0-Beta) bring in changes to directory structure. Some notable changes include:
    * BinaryProjects/ANSDK.xcodeproject has been renamed and moved to sdk/AppNexusSDK.xcodeproject
    * Mediation Adapter targets have been removed from AppNexusSDK.xcodeproject
    * ANSDK target has been removed from AppNexusSDK.xcodeproject
   
   
+ Mediation adapters are now available only via source or CocoaPods.
This will enable publishers to select the mediation networks they need for their inventory strategies
   
+ Third Party Mediation Network Libraries have been removed from code. Publishers integrating mediation via source need to include the libraries themself
A list of supported versions of third-party mediation networks is available in the public documentation
https://wiki.appnexus.com/display/sdk/Mediate+with+iOS+SDK+v6.0
                     
 + If you are currently using Static Library version of AppNexus SDK(libANSDK.a) / Mediation adapter please follow Migration Steps found here
https://wiki.appnexus.com/display/sdk/iOS+v6.0+SDK+Migration+and+Integration#iOSv6.0SDKMigrationandIntegration-migrate-to-6.0
                          
                               
                                    
**Note: Cocoapods integration remains the same from v5.x --> 6.X so it has not been included as a part of Beta release. But will be available as a part of final release**



## 5.5.1
### New Features
+ MS-3778: Added new API to get Video Orientation for BannerVideo and Video Ads

### Mediation partner upgrades/changes
+  Removed support for following mediation Adapter 
    + AdColony SDK
    + AdMarvel SDK
    + Chartboost SDK
    + Vdopia SDK 
    + Vungle SDK 
    + Yahoo SDK

### Improvements/Bug Fixes
+ MS-3902: Removed deprecated APIs
+ MS-3311: Improved Objective-C API Declarations for Swift compatibility.

## 5.4
### New Features
+ MS-3730: Support Rendering for Banner Native ads

### Mediation partner upgrades/changes
+ MS-3495: Upgraded Mopub framework to v5.6.0

### Improvements/Bug Fixes
+ MS-3873: Improved ExposureChange on scroll
+ MS-3194: Removed UIWebView support
+ MS-3798: Added new API to enable publishers to configure skip options for video player
+ Improved Open Measurement Event(Session Finish) for RTB ads

## 5.3
### New Features
+ MS-3789: Ability to customize Video Player Options

### Mediation partner upgrades/changes
+ MS-3803: Upgraded Google AdMob adapter  SDK v7.43.0

### Improvement/Bug Fixes
+ MS-3774: Improved Open Measurement Event(Session Finish)  for BannerAds
+ MS-3712: Resize BannerAd API for Mediation ads
+ MS-3808: Removed videoAdDidClose method to prevent Video Player removal (Github #22)

## 5.2
### New Features
+ MS-3720: Open Measurement SDK support for Native Ads

## 5.1.2
### New Features
+  Added new API for setting Custom User Agent.

## 5.1.1
### Mediation partner SDK upgrades/changes
+ Upgraded Smart Server SDK v7.0.2
+ Made SmartAdAdapter Podspec to be dependent on Smart-Display-SDK Pods

Known issue: Apps integrating Smart Adapter from Code/Binary need to remove i386 and x86_64 architectures in order to be able to push to appstore. Cocoapods integration will work as-is.


## 5.1
### New Features
+ Support for Carthage using script : carthageAppNexusSDK.sh

### Mediation partner SDK upgrades/changes
+ Updated Google AdMob adapter to support GADUnifiedNativeAd and GADMediaView requirements
+ Upgraded Smart Server SDK v7.0    

### Bug Fixes
+ MS-3695: Refactored loadAd and setAutoRefreshInterval: to provide a single code-path for requesting an ad.
+ MS-3707: Fixed bug in how Open Measurement JavaScript is injected into creative html content.
+ MS-3598,MS-3599: Fixed MRAID and Video Ads to respect Safe Area on Top notch devices when running in FullScreen/Expanded mode.

## 5.0.1
### Bug Fix
+ Allow ANNativeAdRequest to download image assets in background (MS-3714)

## 5.0
### New Features
+ Universal Tags version 3, including support for Native ad objects
+ Support for Native Video
+ Open Measurement SDK support for video ads (MS-3388)
+ New delegate method allowing ANBannerAdView object to be paired with ANNativeAdResponse object upon successful load of native ad (MS-3596)
### Mediation partner upgrades/changes
+ Upgrade GoodleAds SDK v7.35.1
+ Remove support for Rubicon SDK (MS-3682)
### Bug Fixes
+ Prevent crashes by preventing ANBannerAdView from loading when width or height are improperly configured (MS-3685)

## 4.12
###  New Features and Bug Fixes 
+ MS-3606: Updated Smart Adapter to v6.10
+ MS-3495: Updated Google Play Ad Adapter (AdMob & DFP) to v7.35.1
+ MS-3633: Added new APIs that expose additional description (`desc2`) and main image size for Native Ads
+ MS-3439: Added the option to send content_url string in Google Mediation requests, use key: `content_url`
+ MS-3583: Ability to pass second_price value to Google DFP Banner Ads. Beta release - please contact your Account Manager for more information about this feature.
Known Issue: Rubicon Mediation Adapter compatibility issues with iOS 12.0 - to be fixed in a future release.

## 4.11.1
###  New Features and Bug Fixes 
+ MS-3527: Attempt to prevent crash in OMIDAppnexusScriptInjector by error checking all MobileSDK inputs and by serializing global properties shared between threads. 
+ MS-3461: Update logic to center video display when video player is expanded to fill the full screen of the device.
 
## 4.11
###  New Features and Bug Fixes 
+ MS-3401: Added an API for enabling/disabling the location access to the creative.
+ MS-3518: Updated the AppNexus GDPR constants to avoid namespace collisions with other SDKs implementing GDPR.
+ MS-3323: Updated SDK Localization for In-app browser's "OK" Button.
+ MS-3462: Fixed video completion tracker not firing consistently.
+ MS-3406: Updated the Mobile Vast Player.

## 4.10
###  New Features and Bug Fixes
+ MS-3181 -- Allow ANInstreamVideoAd to be initialized with inventoryCode and memberId.
+ MS-3409 -- Repair SDK build errors highlighted by Xcode 10beta4.
+ MS-3324 -- Allow designation of arbitrary sizes to trigger full view constraints on banner ad instances.
+ MS-3427 -- Update Banner Native such that mainImage and iconImage are never downloaded automatically.
+ MS-3199 -- Add impression count API for Mediated Native creatives
+ MS-3444 -- Add API to restrict allowed media types for Banner Ad

## 4.9
### New Features
+ MS-3234 -- Open Measurement SDK Support for HTML Banner Ads

## 4.8
### New Features
+ MS-3083 -- Native for Banner Ad View
+ MS-3115 -- Function to set external user id in the SDK for user syncing
+ MS-3279 -- Expose click through url for banner, native, interstitial & video

### Bug Fixes
+ MS-3186 -- Incorrect logic in AdMob mediation code - iOS - native

### Mediation Partner Updates
+ MS-3257 -- Update Facebook Audience Network SDK to latest version
+ MS-3075 -- Update inMobi client side adapter to support latest inMobi SDK

### Versions of Updated Mediation SDK.
+ InMobi                7.1.1
+ FacebookSDK           4.28.1



## 4.7.1
### New Features and Bug Fixes
+ MS-3227 -- GDPR support for SDK
+ MS-3193  -- [iOS SDK] crash


## 4.6
### New Features
+ MS-2113 -- Support autocollapse of interstitials
+ MS-3178 -- Implement exposureChange event


## 4.5
### New Features
+ Banner Video



## 4.4.2
### Bug Fixes
+ MS-3200 - Fixed ANLocalizations overriding parent app localizations


## 4.4.1
### Bug Fixes
+ MS-3197 - Fixed a crash in Creative Id changeset

## 4.4
### Updates
+ MS-2132 - The in-app browser localisations added for different localisations(French, German, Spanish, Swedish and Danish)
+ MS-3096 - Ability to get Creative ID in the SDK from response
+ MS-3187 - iPhone X : WKWebView scrollView gets undesired insets fixed



## 4.3
### Updates
+ MS-3142 - App crashing on iOS 9 when tapping on Native Ad
+ MS-3060 -  Mobile SDK: Close Interstitial when it is clicked
+ MS-3087 - iOS Pre-Roll Placement Video Completion Tracker Not Firing Consistently
+ VID-3227 - Pre-roll video serving mid-roll
+ MS-3101 - Update Rechability Code
+ MS-3170 - SDK Crash


## 4.2
### Updates
+ MS-3097 -- Instream Video new API's to provide info on the video creatives loaded & playing

## 4.1

### Updates
+ AppNexusSDK will now support iOS 9.0 & above only

### Bug Fixes
+ MS-3085 -- Update SDK to respect safe area on iPhone X/iOS 11
+ MS-2985 -- `NSURLConnection` has deprecated methods that are currently in use by the AppNexus SDK
+ MS-2983 -- `MPMoviePlayerViewController` has been deprecated as per iOS 9 but is being used in ANMRAIDUtil


## 4.0.1

### Bug Fixes

+ Resolve CocoaPods build issues.




## 4.0

### New Features

+ MS-2964 -- Replace usage of /mob with /ut in SDK

### Bug Fixes

+ MS-1891 -- Address Facebook SDK star rating deprecation
+ MS-2862 -- Support newly added standard fields on the native creative object
+ MS-2915 -- Send SDK version on /ut requests
+ MS-2931 -- Product Request: Allow device permissions on iOS to be disabled
+ MS-3077 -- Add better support for rotation on iOS
+ MS-3078 -- Add support for loading 1x1 creatives in a banner

+ GitHub Issue #13 -- Stop using EKEventStore




## 3.6

###Mediated SDKs
+Updated the following mediation adapters which were updated to support iOS 11

+ AdMobSDK                         v7.24.1
+ MillenialMediaSDK              v6.6.0
+ RubiconSDK                        v6.4.0
+ AmazonSDK                        v2.2.15.1
+ FacebookSDK                     v4.26.0

## 3.5.1

### Bug Fixes and Updates

+ Removed files related to AdColony Native Mediation. It is no longer supported.

## 3.5

### Bug Fixes and Updates

+ Instream video is only supported in iOS 9 and above
+ MS-3041 - Allow to configure app access rights in SDK

### Mediated SDKs

+   AdColony SDK        v3.1.1


## 3.4

### Bug Fixes and Updates

+   MS-3026 - Add support for about:srcdoc.

### Mediated SDKs

+  Facebook SDK            v4.24.0


## 3.3

### Bug Fixes and Updates

+   MS-2828 - VPAID support for Instream-Video.


## 3.2.1

### Bug Fixes and Updates

+   MS-3016 - Fixed podspec configuration and fake framework import issue in Rubicon mediation adapter..


## 3.2

### Bug Fixes and Updates

+   Fixed AdMarvel banner ad misalignment

### Mediated SDKs

+  Rubicon SDK              v6.3.0


## 3.1.2

### Bug Fixes

+   MS-2984 Video Rendering issue on iOS 10.3

## 3.1

### Bug Fixes and Updates

+   MS-2630  Support for new sizes when mediating Facebook banners

+   MS-2853  Engineer ANJAM so that getCurrentPosition() get the position on-the-fly

+   MS-2954  Add Google adapter subspec to Cocoapods

+   PR-12  Integrate third party PR: Fix reachability leak


#### Instream Video Ads

+   Modify the parent controller that is being set to load the click thru url.

+   Update the custom targeting params format

## 3.0

### New Features

+ Support for instream video.


### Bug Fixes and Updates

+ Remove iAd.
+ Minimum supported iOS version is now v8.0



## 2.14

### Mediated SDKs

+   AdMarvel        v4.2.0
+   Rubicon         v6.1.0
+   SmartAd Server  v6.6
+   Millenial Media v6.3.1
+   AdMob           v6.4.1

### Bug Fixes

+   MS-2839 Fix Anjam and Sdk communication for creative served in iframe

+   MS-2856 Error building with Carthage

+   MS-2841 Add a "ping" feature to the SDK without anjam.js injection



## RC 2.13.2

### Bug Fixes

+ MS-2212  Allow RTB banners to fit full screen.  New BOOL property: shouldResizeAdToFitContainer.

+ MS-2820  Support multiple sizes in SDK ad request.

+ PR-10  Integrate third party PR: project and schema updates per Xcode 8.



## RC 2.13.1

+ Expose ANAdAdapterMillennialMediaBase.h In ANSDKMillennialMediaAdapter Binary Target

+ Expose ANSDKSettings.h In ANSDK Binary Target



## RC 2.13

### New Features

+ MS-2580 Added switch to enable HTTPS in SDK for calls made by the AppNexus SDK

    + Currently, ad calls may not always be ATS compliant. The AppNexus ad server will be fully ATS compliant by the end of 2016 without the need for an SDK change.

    + Because the AppNexus SDK does not control ad calls made by mediated SDKs, ATS compliance for mediated SDKs is the responsibility of each respective vendor. As mediated SDKs become ATS compliant the AppNexus SDK will be upgraded to support them.

+ MS-2584 Added static method to pass Nexage Site ID into Millennial SDK mediated adapter

### Bug Fixes

+ MS-2664 Fixed click-through issue affecting some ads loading in WKWebView

+ MS-2227 Multiple values for a single key now supported for AppNexus ad serving

### Mediated SDKs

+  Amazon SDK              v2.2.15
+  AdColony SDK            v2.6.2
+  AdMob SDK               v7.10.1
+  Chartboost SDK          v6.4.7
+  Facebook SDK            v4.15.0
+  Millennial Media SDK    v6.3.0
+  MoPub SDK               v4.9.0
+  Vungle SDK              v4.0.5
+  Yahoo Flurry SDK        v7.6.4



## RC 2.12.1

### Mediated SDKs

+ Facebook SDK Version 4.14.0

## RC 2.12

### Bug Fixes

+ MS-2382 Allow numbers passed as strings in mraid.js resizeProperties & expandProperties

+ MS-2332 Load interstitial full-screen ads in a web view the size of the screen

+ Updated client testing endpoints to ib-test.adnxs.com

+ Load MRAID/ANJAM scripts only in main frame

+ Open default browser only for a new window navigation

### Mediated SDKs

No change

## RC 2.11

### New Features

+ MS-2211 Use WKWebView for the in-app browser on iOS 8+

+ MS-2214 Suppress user selection of ads

### Bug Fixes

+ MS-2163 Schedule NSURLConnection of ANAdFetcher in the current run loop for mode NSRunLoopCommonModes

+ MS-2163 Fully load WKWebView in the background before sending the `[ANAdDelegate adDidReceiveAd]` callback

+ MS-2214 Allow the app user to dismiss the in-app App Store window even if the ad view which presented it has been deallocated

+ MS-2214 Disable video autoplay on iPhones running iOS 9 and below

### Mediated SDKs

No change

## RC 2.10

### New Features

+ MS-2251 Banner ads are rendered in a WKWebView instead of UIWebView in iOS 8+

+ MS-2307 Ability to traffic full-screen interstitial creatives

### MS-2316 Contains the following mediated SDKs:

+ AdMob SDK Version 7.8.1

+ Facebook SDK Version 4.12.0

+ Amazon SDK Version 2.2.14

+ Millennial Media SDK Version 6.1.0

+ MoPub SDK Version 4.6.0

+ InMobi SDK Version 5.3.1

+ VDOPIA Lightweight SDK v1.4

+ Vungle SDK 3.2.1

+ AdColony SDK 2.6.1

+ Chartboost SDK 6.4.4

+ Yahoo Flurry SDK 7.6.3

## RC 2.9

### New Features

+ MS-2031 AdMob Native Mediation

### Bug Fixes

+ Improved behavior for ANJAM window listener

### MS-1913 Contains the following mediated SDKs:

+ AdMob SDK Version 7.6.0

+ Facebook SDK Version 4.9.1

+ Amazon SDK Version 2.2.13

+ Millennial Media SDK Version 6.1

+ MoPub SDK Version 4.1.0

+ InMobi SDK Version 5.2.0

+ VDOPIA Lightweight SDK Version 4

+ Vungle SDK 3.2.0

+ AdColony SDK 2.6.1

+ Chartboost SDK 6.2.1

+ Yahoo Flurry SDK 7.3.0

## RC 2.8

### New Features

+ MS-1701 Added public API to support passing inventory code and member ID in lieu of placement ID

### MS-1712 Contains the following mediated SDKs:

+ AdMob SDK Version 7.5.2

+ Amazon SDK Version 2.2.11

+ Facebook SDK Version 4.8.0

+ Millennial Media SDK Version 6.1.0

+ MoPub SDK Version 4.1.0

+ InMobi SDK Version 5.0.2

+ VDOPIA Lightweight SDK Version 4

+ Vungle SDK 3.2.0

+ AdColony SDK 2.6.0

+ Chartboost SDK 6.0.1

+ Yahoo Flurry SDK 7.3.0

### Known Issues

+ Amazon SDK 2.2.11 emits warnings in Xcode 7 of the following kind: "Warning: Could not resolve external type c:objc(cs)". These will be addressed in a subsequent release.

## ~~RC 2.7~~

## RC 2.6

### Bug fixes:

+ MS-1573 Improve how location is passed on a native ad request url

### Other changes:

+ MS-1389 Updated test project & sample app for Xcode 7 / iOS 9

+ MS-1389 Bitcode ANSDK binary can be built by running "./buildANSDK.sh -b"

### MS-1654 Contains the following mediated SDKs:

+ AdMob SDK Version 7.5.1

+ Amazon SDK Version 2.2.10

+ Facebook SDK Version 4.7.0

+ Millennial Media SDK Version 6.1.0

+ MoPub SDK Version 3.11.0

+ InMobi SDK Version 4.5.3

+ VDOPIA Lightweight SDK Version 4

+ Vungle SDK 3.2.0

+ AdColony SDK 2.6.0

+ Chartboost SDK 5.5.3

+ Yahoo Flurry SDK 7.2.1

## RC 2.5

### Bug fixes:

+ MS-1503 Fixed customEventInterstitialWillPresent call in ANGADCustomInterstitialAd.m

### Other changes:

+ MS-1511 Xcode 7 / iOS 9 updates

+ MS-1371 Increase interstitial timeout to 4.5 minutes

### MS-1519 Contains the following mediated SDKs:

+ AdMob SDK Version 7.4.1

+ Amazon SDK Version 2.2.10

+ Facebook SDK Version 4.5.1

+ Millennial Media SDK Version 6.0.1

+ MoPub SDK Version 3.11.0

+ InMobi SDK Version 4.5.3

+ VDOPIA Lightweight SDK Version 4

+ Vungle SDK 3.1.2

+ AdColony SDK 2.5.3

+ Chartboost SDK 5.5.3

+ Yahoo Flurry SDK 7.0.0

## RC 2.4

### Bug fixes:

+ MS-1365 Fix handling of custom keywords on ANNativeAdRequest

+ MS-1306 Improved handling of clickable elements for native ad views

+ MS-1331 Expose ANAdAdapterNativeInMobi header in binary output

### Other changes/additions:

+ MS-1238 Added request, response notification broadcasts

+ MS-1366 Removed old ANGender enum values & banner resize callbacks

+ MS-1333 Improved Binary Build Script

### New mediation adapters:

+ MS-1321 Yahoo Flurry Banner, Interstitial, Native

+ MS-1413 Millennial Banner, Interstitial (rewritten for MMAdSDK 6.0.1)

### MS-1413 Contains the following mediated SDKs:

+ AdMob SDK Version 7.3.1

+ Amazon SDK Version 2.2.8

+ Facebook SDK Version 4.4.0

+ Millennial Media SDK Version 6.0.1

+ MoPub SDK Version 3.9.0

+ InMobi SDK Version 4.5.3

+ VDOPIA Lightweight SDK Version 4

+ Vungle SDK 3.1.2

+ AdColony SDK 2.5.3

+ Chartboost SDK 5.5.1

+ Yahoo Flurry SDK 6.5.0

## RC 2.3.1

### Bug fixes:

+ MS-1317 Addressed iPad in-app browser compile issue

## RC 2.3

### Bug fixes:

+ MS-1219 Removed OpenUDID dependency

+ MS-1265 Move location of kANAdFetcherDidReceiveResponseNotification

+ MS-1267 Testing improvements

### New mediation adapters:

+ MS-1107 AdColony Native

### Contains the following mediated SDKs:

+ AdMob SDK Version 7.3.1

+ Amazon SDK Version 2.2.8

+ Facebook SDK Version 4.2.0

+ Millennial Media SDK Version 5.4.1

+ MoPub SDK Version 3.8.0

+ InMobi SDK Version 4.5.3

+ VDOPIA Lightweight SDK Version 4

+ Vungle SDK 3.0.13

+ AdColony SDK 2.5.1

+ Chartboost SDK 5.4.0

## RC 2.2

### Feature additions:

+ MS-910 Interstitials with transparent backgrounds now supported on iOS 8

+ MS-941 Enhanced user interaction detection on ad views

+ MS-982 Auto-detect a banner root view controller if one isn't provided

### Bug fixes:

+ MS-882 Handle banner, interstitial, native invalid network detection separately

+ MS-970, MS-1038 Binary build scripts now work in directories where the file path contains one or more spaces

+ MS-971 Fixed native ad click fallback behavior

+ MS-1000 Fire adWillClose and adDidClose on ANInterstitialAd

### Internal improvements:

+ MS-540 Add ANLogging support in ANMoPubMediationBanner & ANMoPubMediationInterstitial

+ MS-962 Simplify IDFA retrieval based on 6.0 deployment target

+ MS-976, MS-1042, MS-1055 Break apart ANAdResponse into ANAdServerResponse & ANAdFetcherResponse

+ MS-975 Improved AdFetcher error handling

+ MS-1022, MS-1054 Added AN namespace to all category methods

+ MS-1024 Removed ANBasicConfig

### Mediation adapter bug fixes:

+ MS-963 Fix for isReady in Amazon interstitial adapter

+ MS-1113 Silence warning in Millennial adapters when compiling for iOS 8.3

+ MS-1186 Address deprecated methods in ANGADCustomBannerAd & ANGADCustomInterstitialAd from Google AdMob SDK 7.2.1

+ MS-1188 Simplify iAd adapters based on 6.0 deployment target

+ MS-1193 Improved error code handling for MoPub & Millennial adapters

### New mediation adapters:

+ MS-942 InMobi Banner, Interstitial, Native

+ MS-1045 AdColony Interstitial

+ MS-1047 Vungle Interstitial

+ MS-1048 VDOPIA Banner, Interstitial

+ MS-1071 Chartboost Interstitial

### Contains the following mediated SDKs:

+ AdMob SDK Version 7.2.1

+ Amazon SDK Version 2.2.6

+ Facebook SDK Version 4.1.0

+ Millennial Media SDK Version 5.4.1

+ MoPub SDK Version 3.7.0

+ InMobi SDK Version 4.5.1

+ VDOPIA Lightweight SDK Version 4

+ Vungle SDK 3.0.13

+ AdColony SDK 2.5.0

+ Chartboost SDK 5.2.1

## RC 2.1

+ MS-856, MS-868, MS-875, MS-916, MS-918, MS-925 Implemented AppNexus Native Ad Console Support.

+ MS-932 Introduced namespaced `ANGender` enum values (e.g. `ANGenderMale`). Deprecated existing values (e.g. `MALE`).

+ Updated to meet MRAID 2.0 compliance standards

### Other Feature Additions:

+ MS-868 Added dependency on StoreKit framework, App Store URLs will open directly in the app instead of opening in the AppStore app when `opensInNativeBrowser` is set to NO on the ad view.

+ MS-900 Added dependency on EventKitUI framework, user will be presented with a calendar event edit screen if an ad calls `mraid.createCalendarEvent`

+ UIWebView performance enhancements

### Bug fixes:

+ MS-888 Clear AmazonAdView delegate on dealloc

+ MS-902 Fixed malformed URL issue caused by mediated networks not present in app

+ MS-934 Allow background color for banner to be set from .nib file or storyboard

### Includes the following mediated network SDKs:

+ Google SDK Version 7.0.0

+ Amazon SDK Version 2.1.9

+ Facebook SDK Version 3.23

+ Millennial Media SDK Version 5.4.1

+ MoPub SDK Version 3.4.0

Note: The AdMob and DFP mediation adapters have been updated to work with the new framework distribution mechanism for the Google Ads SDK (in version 7.0.0).


## RC 1.21 (2.0)

+ AppNexus Native API 1.0, with support for MoPub and Facebook mediation.

### Other Bug Fixes:

+ ANLocation formatting on the ad call

+ KVO removeObserver exceptions

+ MRAID ad with custom close in expanded state did not correctly collapse back to default state.

+ Improved importing of SDK bundle resources.

### 3rd party SDK updates:

+ AdMob 6.12.2

+ Amazon 2.1.4

+ Facebook 3.20

+ MoPub 3.2.0



## RC 1.20



+ `ANAdProtocol landingPageLoadsInBackground`: Controls the SDK's behavior when an ad is clicked. The default behavior (`YES`) is to load the landing page in the background until the initial payload finishes loading and then present a fully rendered page to the user. Setting this to `NO` will cause the in-app browser to immediately become visible and display the unrendered landing page. Note that setting this to `NO` when an ad redirects to the app store may cause the in-app browser to briefly flash on the screen.



+ `ANAdProtocol setLocationWithLatitude:longitude:timestamp:horizontalAccuracy:precision:`: Provide a precision parameter when passing a user's location from a `CoreLocation` instance that will cause all location information to be internally rounded to the specified number of digits after the decimal before being passed to the ad server. The nominal resolution of digits after the decimal to distance is 2 digits to ~1 km, 3 digits to ~100m, 4 digits to ~10m. If set to -1, then full resolution is passed.



+ `ANBannerView (ANBannerViewAdAlignment) alignment`: Overrides the alignment of the ad unit within the banner view, in the event the banner view frame is larger than the ad. The default alignment is `ANBannerViewAdAlignmentCenter`. Set this property to align the ad to the top left, top center, top right, center left, center right, bottom left, bottom center or bottom right.



### Other Feature Additions:



+ Amazon mediation adapters.

+ Adopted Objective-C Modern Best Practices in Public APIs.

+ Simple banner app.



### Bug fixes:



+ Removed support for DFP Swipeable Banner, a deprecated API.

+ MRAID viewability timer reference set to strong.

+ ANWebView delegate set to `nil` on dealloc.



### 3rd party SDK updates:



+ MoPub 3.0.0

+ Amazon 2.1.2

+ Google 6.12.0

+ FB Audience Network 3.18.2

+ Millennial Media 5.4.1



Minimum deployment target is iOS 6.0.



### Notes:



To enable Amazon monetization, your app must register itself with Amazon when your application starts in your main app delegate:



    #include "ANAdAdapterBaseAmazon.h"

    ...

    [ANAdAdapterBaseAmazon setAmazonAppKey: "YOUR APP KEY"];
