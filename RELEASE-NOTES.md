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
