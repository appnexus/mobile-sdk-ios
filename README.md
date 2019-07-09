Appnexus iOS SDK
=====================

```sh
The next version of MobileSDK, v6.0 introduces changes intended to make the SDK lightweight, minimizing its 
footprint on disk and in memory. This version includes the following changes, but otherwise introduces 
no new functionality

- The SDK itself is now built only as a dynamic framework.
- To streamline mediation adapter upgrades, we are removing mediation adapter libraries.
- Mediation adapters can now be included only via source code or Cocoapods
  1. This benefits the publisher to choose the mediation networks needed.
  2. The supported version of third-party mediation network will be provided in the documentation on our wiki
```

See the documentation on our wiki here: http://wiki.appnexus.com/x/dhAtAw

Get the latest release notes here: http://wiki.appnexus.com/x/L4aTAw

**Please Note: This SDK is intended to complement the AppNexus Console; it does not work with OAS. The OAS iOS SDK can be found here:** https://github.com/appnexus/oas-mobile-sdk-ios

To file an issue or request an enhancement please visit the AppNexus Customer Support Portal (https://support.appnexus.com). **We do not accept GitHub issues.**

## Use Cocoapods?

Easily include the AppNexus SDK in your Podfile:

```
platform :ios, '9.0'

target 'MyAmazingApp' do
  pod 'AppNexusSDK'
end
```

