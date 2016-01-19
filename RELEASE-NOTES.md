## Version 3.0-Alpha-1

### New Features

For the interstitial ad format:

1. VAST video demand can now serve alongside HTML & mediation demand.
2. A more robust request/response format is supported in the backend which reduces latency for fetching ads
3. Impressions are counted client-side when the ads become viewable
4. The countdown timer & close button look and feel has been redesigned 

### Bug Fixes

1. Improved behavior for ANJAM window listener 

### Known Issues

* **Setting the reserve price directly on ANInterstitialAd is not supported**

_Workaround_: Set the reserve price for any interstitial placements in Console.

* **VAST error tracking is not supported**

_Workaround_: None.

* **VAST companion ads are not supported**

_Workaround_: None.

* **Ad server is returning 1x1 HTML ads which are unsupported by the SDK**

_Workaround_: Monitor impression traffic and block 1x1 creatives on your ad profile in Console in order to mitigate any fill issues.

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
