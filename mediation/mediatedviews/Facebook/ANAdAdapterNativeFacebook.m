/*   Copyright 2014 APPNEXUS INC
 
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

#import "ANAdAdapterNativeFacebook.h"

@interface ANAdAdapterNativeFacebook ()

@property (nonatomic) FBNativeAd *fbNativeAd;
@property (nonatomic) FBMediaView *fbMediaView;
@property (nonatomic) FBMediaView *fbAdIcon;

@end

@implementation ANAdAdapterNativeFacebook

@synthesize requestDelegate = _requestDelegate;
@synthesize nativeAdDelegate = _nativeAdDelegate;
@synthesize expired = _expired;

#pragma mark ANNativeCustomAdapter

- (void)requestNativeAdWithServerParameter:(nullable NSString *)parameterString
                                  adUnitId:(nullable NSString *)adUnitId
                       targetingParameters:(nullable ANTargetingParameters *)targetingParameters {
    self.fbNativeAd = [[FBNativeAd alloc] initWithPlacementID:adUnitId];
    self.fbNativeAd.delegate = self;
    [self.fbNativeAd loadAd];
}

-(BOOL) getMediaViewsForRegisterView:(nonnull UIView *)view{
    
    for (UIView *subview in [view subviews]){
        if([subview isKindOfClass:[FBMediaView class]]){
            FBMediaView *fbAdView = (FBMediaView *)subview;
            switch (fbAdView.nativeAdViewTag) {
                case FBNativeAdViewTagIcon:
                    self.fbAdIcon = fbAdView;
                    break;
                default:
                    self.fbMediaView = fbAdView;
                    break;
            }
        }else if([subview isKindOfClass:[UIView class]])
        {
            [self getMediaViewsForRegisterView:subview];
        }
        if(self.fbMediaView && self.fbAdIcon){
            break;
        }
    }
    if(self.fbMediaView) {
        return YES;
    }
    
    return NO;
}

- (void)registerViewForImpressionTrackingAndClickHandling:(nonnull UIView *)view
                                   withRootViewController:(nonnull UIViewController *)rvc
                                           clickableViews:(nullable NSArray *)clickableViews {

    if([self getMediaViewsForRegisterView:view]){
        if(clickableViews.count != 0) {
            [self.fbNativeAd registerViewForInteraction:view
                                              mediaView:self.fbMediaView
                                               iconView:self.fbAdIcon
                                         viewController:rvc
                                         clickableViews:clickableViews];
            
        }else {
            [self.fbNativeAd registerViewForInteraction:view
                                              mediaView:self.fbMediaView
                                               iconView:self.fbAdIcon
                                         viewController:rvc];
        }
    }
    else{
        ANLogDebug(@"View does not contain mediaView for registerViewForImpressionTracking.");
    }
}

- (void)dealloc {
    [self unregisterViewFromTracking];
}

- (BOOL)hasExpired {
    return ![self.fbNativeAd isAdValid];
}

- (void)unregisterViewFromTracking {
    [self.fbNativeAd unregisterView];
    self.fbNativeAd = nil;
}

#pragma mark - FBNativeAdDelegate

- (void)nativeAd:(FBNativeAd *)nativeAd didFailWithError:(NSError *)error {
    ANLogError(@"Error loading Facebook native ad: %@", error);
    ANAdResponseCode code = ANAdResponseInternalError;
    if (error.code == 1001) {
        code = ANAdResponseUnableToFill;
    }
    [self.requestDelegate didFailToLoadNativeAd:code];
}

- (void)nativeAdDidLoad:(FBNativeAd *)nativeAd {
    ANNativeMediatedAdResponse *response = [[ANNativeMediatedAdResponse alloc] initWithCustomAdapter:self
                                                                                        networkCode:ANNativeAdNetworkCodeFacebook];
    response.title = nativeAd.headline;
    response.body = nativeAd.bodyText;
    response.callToAction = nativeAd.callToAction;
    response.customElements = @{ kANNativeElementObject : nativeAd};

    [self.requestDelegate didLoadNativeAd:response];
}

- (void)nativeAdDidClick:(FBNativeAd *)nativeAd {
    [self.nativeAdDelegate adWasClicked];
    [self.nativeAdDelegate willPresentAd];
    [self.nativeAdDelegate didPresentAd];
}

- (void)nativeAdDidFinishHandlingClick:(FBNativeAd *)nativeAd {
    [self.nativeAdDelegate willCloseAd];
    [self.nativeAdDelegate didCloseAd];
}

- (void)nativeAdWillLogImpression:(FBNativeAd *)nativeAd {
    ANLogDebug(@"Facebook Native ad impression is being captured.");
    [self.nativeAdDelegate adDidLogImpression];
}

@end
