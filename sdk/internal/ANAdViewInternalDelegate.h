/*   Copyright 2013 APPNEXUS INC
 
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

#import <UIKit/UIKit.h>



// NB  Native does not use ANAdViewInternalDelegate, but instead has its own specific delegates for the request and response halves of Native entry point.
//     See ANNativeAdRequestDelegate and ANNativeAdDelegate (for response).
//
@protocol ANAdViewInternalDelegate <NSObject>


@required
- (void)adDidReceiveAd;
- (void)adRequestFailedWithError:(NSError *)error;

- (void)adWasClicked;
- (void)adWillPresent;
- (void)adDidPresent;
- (void)adWillClose;
- (void)adDidClose;
- (void)adWillLeaveApplication;
- (void)adDidReceiveAppEvent:(NSString *)name withData:(NSString *)data;

- (NSString *)adTypeForMRAID;

- (UIViewController *)displayController;
- (BOOL)opensInNativeBrowser;
- (BOOL)landingPageLoadsInBackground;

- (void)adInteractionDidBegin;
- (void)adInteractionDidEnd;


@end



@protocol ANBannerAdViewInternalDelegate <ANAdViewInternalDelegate>

- (NSNumber *)transitionInProgress;

@end



@class ANMRAIDOrientationProperties;

@protocol ANInterstitialAdViewInternalDelegate <ANAdViewInternalDelegate>

- (void)adFailedToDisplay;
- (void)adShouldClose;
- (void)adShouldSetOrientationProperties:(ANMRAIDOrientationProperties *)orientationProperties;
- (void)adShouldUseCustomClose:(BOOL)useCustomClose;

@end

