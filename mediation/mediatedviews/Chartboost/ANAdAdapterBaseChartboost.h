/*   Copyright 2015 APPNEXUS INC
 
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

#import <Chartboost/Chartboost.h>

extern NSString *const kANAdAdapterBaseChartboostCBLocationKey;

/**
 Please instantiate the Chartboost SDK in your App Delegate, like this:
 
 @code
 [ANAdAdapterBaseChartboost startWithAppId:@"552d680204b01658a177f467"
                              appSignature:@"8051c2d6e6178ad46448e54460c255f04cfc50e0"];
 @endcode

 Additionally, please pass in the appropriate CBLocation for the place in your app where the 
 interstitial will be shown as demonstrated in the example below. The full list of CBLocation
 values can be found in Chartboost.h in the Chartboost Framework.
 
 @code
 ANInterstitialAd *interstitialAd = [[ANInterstitialAd alloc] initWithPlacementId:@"1326299"];
 ...
 [interstitialAd addCustomKeywordWithKey:kANAdAdapterBaseChartboostCBLocationKey
                                   value:CBLocationHomeScreen];
 ...
 [interstitialAd loadAd];
 @endcode
 
 */
@interface ANAdAdapterBaseChartboost : NSObject

+ (void)startWithAppId:(NSString *)appId
          appSignature:(NSString *)appSignature;

@end