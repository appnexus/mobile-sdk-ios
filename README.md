Appnexus iOS SDK
=====================

```
Upcoming change: Native impression counting methodology will follow the count-on-render methodology that is used for banner creatives - an impression will fire as soon as the native advertisement renders, regardless of its viewability, or length of time on the screen. This will ensure greater accuracy and better deliverability, thus improving overall yield.
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

