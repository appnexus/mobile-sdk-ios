AdColony iOS SDK
==================================
Modified: 2016/06/23  
SDK Version: 2.6.2  

iOS 9 
----------------------------------
iOS 9 has introduced a couple of changes that will affect your integration of our new SDK. Please note that following our iOS 9 [integration instructions](https://github.com/AdColony/AdColony-iOS-SDK/wiki/iOS-9) is a strict requirement for apps compiling against the iOS 9 SDK (Xcode 7). Failure to do so will result in ads being turned off for your application. 

To Download:
----------------------------------
The simplest way to obtain the AdColony iOS SDK is to click the "Download ZIP" button located in the right-hand navigation pane of the Github repository page.

In addition, you can add the AdColony SDK to your project using [CocoaPods](https://cocoapods.org/). Just add the following to your Podfile
```
pod 'AdColony'
```


Contains:
----------------------------------
* AdColony.framework (iOS)
* Sample Apps
  * AdColonyAdvanced
  * AdColonyInstantFeed
  * AdColonyV4VC
* W-9 Form.pdf

Getting Started with AdColony:
----------------------------------
New and returning users should review the [quick start guide](https://github.com/AdColony/AdColony-iOS-SDK/wiki), which contains detailed integration instructions.

2.6.2 Change Log:
----------------------------------
* Tracking event for in-feed, native ad video engagement
* Periodic reporting of asset download metadata
* Miscellaneous bug fixes

2.6.1 Change Log:
----------------------------------
* Logic to prevent gradual thread buildup in airplane mode
* Decreased time to initial ad playback
* Improved logging
* Miscellaneous bug fixes

2.6.0 Change Log:
----------------------------------
* Fully tested and certified for iOS 9 
* iOS 9 multitasking compatibility
* Optimized ad-caching algorithms
* Removed requirement for ObjC linker flag
* App install can now be triggered from in-feed native ads
* `getVirtualCurrencyRewardsAvailableTodayForZone:` method no longer supported
* New sample applications (Swift and ObjC)
* SDK is compiled with bitcode
* Improved logging
* Xcode 7 support
* Miscellaneous bug fixes

2.5.3 Change Log:
----------------------------------
* Fixed bug causing view-dismissal code to be called multiple times
* Miscellaneous bug fixes

2.5.2 Change Log:
----------------------------------
* AdColonyNativeAdDelegate now reports engagement events from both in-feed and expanded states
* Centered text in standard in-video engagement (IVE) button

2.5.1 Change Log:
----------------------------------
* Native ads now maintain a weak reference to the app’s view controller
* Native ad callback for capturing ad-engagement events
* Serialized view-controller-dismissal and ad-finished callbacks (ad-finished fires second)

2.5.0 Change Log:
----------------------------------
* WKWebView for iOS 8
* API for reporting in-app purchases (IAPs)
* New ad-completion callback to support In-App Purchase Promo (IAPP) feature
* AdColonyAdInfo class for communicating ad-specific details
* Increased minimum OS version for showing videos to 6.0; SDK disables itself on prior versions
* ODIN1, OpenUDID, and MAC identifiers no longer collected

2.4.13 Change Log:
----------------------------------
* Fully compatible with iOS 8.1
* Stylistic improvements to in-video engagement feature
* Fixed rare black screen on iPad Airs running iOS 8
* Fixed first-time install crash bug caused by Unity 4.5
* Miscellaneous bug fixes

2.4.12 Change Log:
----------------------------------
* Fixed memory leak caused by UIWebView on iOS 8
* Addressed multiple conflicts with Unity plugin
* Improved orientation functionality

2.4.10 Change Log:
----------------------------------
* Fully tested against the iOS 8 Gold Master
* Refinements and optimizations to AdColony Instant-Feed
* Bug fixes 

2.3.12 Change Log:
----------------------------------
* Initial public release of AdColony Instant-Feed
* New requirement: minimum Xcode Deployment Target of iOS 5.0
* New public class AdColonyNativeAdView which implements AdColony Instant-Feed
* AdColony class new method to request AdColonyNativeAdView objects
* Removed collection of OpenUDID, ODIN1, and MAC-SHA1 device identifiers on iOS 7+
* Removed collection of IDFV device identifier altogether
* Bug fixes and threading improvements

2.2.4 Change Log:
----------------------------------
* Added support for the 64-bit ARM architecture on new Apple devices
* The AdColony iOS SDK disables itself on iOS 4.3 (iOS 5.0+ is fully supported); the minimum Xcode Deployment Target remains iOS 4.3
* Bug fixes

2.2 Change Log:
----------------------------------
* AdColony 2.2 has been fully tested against the most recent iOS 7 betas and gold master seed
* AdColony is now packaged as a framework and its API is not backwards compatible with AdColony 2.0 integrations
* AdColony relies on additional frameworks and libraries; see the [quick start guide](https://github.com/AdColony/AdColony-iOS-SDK/wiki) for details. 
* The AdColony class has had methods removed and renamed for consistency
* The AdColonyDelegate protocol has had methods removed and renamed; its use is no longer mandatory
* The AdColonyTakeoverAdDelegate protocol has been renamed to AdColonyAdDelegate; it has had methods removed and renamed
* Improved detail and transparency of information regarding ad availability
* Various user experience improvements during ad display
* Increased developer control over network usage; improved efficiency and reliability
* Added console log messages to indicate when the SDK is out of date
* Bug fixes

2.0.1.33 Change Log:
----------------------------------
* Removed all usage of Apple's UDID in accordance with Apple policy

2.0 Change Log:
----------------------------------
* Support for Xcode 4.5, iOS 6.0, iPhone 5, and new "Limit Ad Tracking" setting
* Removed support for armv6 architecture devices
* Requires Automatic Reference Counting (ARC) for AdColony library (or whole project)
* Numerous bug fixes, stability improvements and performance gains
* Built-in support for multiple video views per V4VC reward
* Can collect per-user metadata that unlocks higher-value ads
* New sample applications
* Simplified interface for apps that need to cancel an ad in progress
* Simplified interface for apps that need custom user IDs for server-side V4VC transactions
* Improved log messages for easier debugging


Sample Applications:
----------------------------------
Included are three sample apps to use as examples and for help on AdColony integration, each of which has been written in Swift and ObjC. The basic app allows users to launch an ad, demonstrating simple usage of AdColony. The currency app demonstrates how to implement videos-for-virtual currency (V4VC) to enable users to watch videos in return for in-app virtual currency rewards (with currency balances stored client-side). The Instant-Feed app demonstrates recommended usage of AdColony's native ad unit within the context of a social feed application.


Legal Requirements:
----------------------------------
By downloading the AdColony SDK, you are granted a limited, non-commercial license to use and review the SDK solely for evaluation purposes.  If you wish to integrate the SDK into any commercial applications, you must register an account with [AdColony](https://clients.adcolony.com/signup) and accept the terms and conditions on the AdColony website.

Note that U.S. based companies will need to complete the W-9 form and send it to us before publisher payments can be issued.


Contact Us:
----------------------------------
For more information, please visit AdColony.com. For questions or assistance, please email us at support@adcolony.com.

