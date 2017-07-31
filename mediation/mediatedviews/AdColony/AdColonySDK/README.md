# AdColony iOS SDK
* Modified: March 29, 2017  
* SDK Version: 3.1.1

## Overview
Increase your revenue with the advertising SDK trusted by the world’s top publishers. AdColony delivers high-definition Instant-Play™ video ads that can be displayed anywhere within your application. AdColony contains V4VC™, a secure system for rewarding users of your app with virtual currency upon the completion of video plays.

For detailed information about the AdColony SDK, see our [iOS SDK documentation](https://github.com/AdColony/AdColony-iOS-SDK-3/wiki).

**Note:** The AdColony Compass™ early access program has ended, and we are no longer accepting new partners. Publishers who are currently using those services should email compass@adcolony.com for more details.

## Usage

**Note:** iOS 10 has introduced a change that will affect your integration of the AdColony iOS SDK. Please refer to our [integration instructions](https://github.com/AdColony/AdColony-iOS-SDK-3/wiki/Xcode-Project-Setup) for details.

### Installation

#### Manual

1. Drag and drop the AdColony.framework into your project and refer to our [Xcode Project Setup](https://github.com/AdColony/AdColony-iOS-SDK-3/wiki/Xcode-Project-Setup#adding-the-framework-to-your-xcode-project) page for next steps.

#### Cocoapods

1. Include the AdColony reference in your pod file

    `pod 'AdColony'`

#### Updating from 2.x:
Please note that updating from our 2.x SDK is not a drag and drop update, but rather includes breaking API and process changes. In order to take advantage of the 3.x SDK, a complete re-integration is necessary. Please review our [documentation](https://github.com/AdColony/AdColony-iOS-SDK-3/wiki) to get a better idea on what changes will be necessary in your app.

### Quick Start
The basics of using the AdColony SDK to serve ads to your users are:
1. Configure the service
1. Request an ad *(We recommend requesting a new ad when an ad expires)*
1. Show the ad

For example:

```ObjC
AdColonyInterstitial *_ad;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [AdColony configureWithAppID:/* app_id */
                         zoneIDs:@[/* zone_id_1, zone_id_2 */]
                         options:nil
                      completion:nil
    ];

    return YES;
}

- (void)requestInterstitial {
    [AdColony requestInterstitialInZone:/* zone_id_1 */
        options:nil
        success:^(AdColonyInterstitial *ad) {
            _ad = ad;
        }
        failure:nil
     ];
}

- (void)showInterstitial {
    [_ad showWithPresentingViewController:self];
}
```

For detailed information about the AdColony SDK, see our [iOS SDK documentation](https://github.com/AdColony/AdColony-iOS-SDK-3/wiki).

## Legal Requirements
By downloading the AdColony SDK, you are granted a limited, non-commercial license to use and review the SDK solely for evaluation purposes.  If you wish to integrate the SDK into any commercial applications, you must register an account with AdColony and accept the terms and conditions on the AdColony website.

Note that U.S. based companies will need to complete the W-9 form and send it to us before publisher payments can be issued.

## Contact Us
For more information, please visit AdColony.com. For questions or assistance, please email us at support@adcolony.com.
