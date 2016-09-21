
README -- SDKIntegrationKeys.plist
======================================

The keys in this property list are taken from the integration
instructions published by each mediated SDK at the last time they were
updated.  The keys are listed below per SDK.  Only the keys are
listed, see SDKIntegrationKeys.plist for their values.

(See mobile-sdk-ios/mediation/mediatedviews/README.txt for a list of
SDK versions and date of last update.)

Assume all keys are REQUIRED for the given SDK to function properly,
unless otherwise noted.  Please copy (or recreate) the key and its
value in the designated Info.plist of the app into which you are
integrating the AppNexus SDK.

Most of the following keys have nuances of meaning and/or
relationships to legacy keys.  Please consider Apple documentation
regarding CocoaKeys:

  https://developer.apple.com/library/ios/documentation/General/Reference/InfoPlistKeyReference/Articles/CocoaKeys.html



AdColony
  NSAppTransportSecurity[1]


Amazon
  LSApplicationQueriesScheme
  NSAppTransportSecurity[1]


Chartboost
  FIX


Facebook
  FIX


GoogleAdMob
  FIX


iAd
  FIX


InMobi
  FIX


MillennialMedia
  NSAppTransportSecurity[1]
  NSLocationWhenInUseUsageDescription[2]

MoPub
  FIX


Vdopia
  FIX


Vungle
  NSAppTransportSecurity[1]
  UIViewControllerBasedStatusBarAppearance  (optionally set to NO)


Yahoo
  FIX




  NOTES
    [1] See developer.apple.com if exceptions to NSAppTransportSecurity are needed.
    [2] Customize this string for your application.
        NSLocationWhenInUseUsageDescription supercedes NSLocationUsageDescription.




