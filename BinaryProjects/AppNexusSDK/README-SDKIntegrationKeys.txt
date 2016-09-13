
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



AdColony
  LSApplicationQueriesScheme
  NSAppTransportSecurity[1]


FIX -- ADD




[1] NOTE  Please see developer.apple.com if exceptions to
          NSAppTransportSecurity are needed:

  https://developer.apple.com/library/ios/documentation/General/Reference/InfoPlistKeyReference/Articles/CocoaKeys.html





